package support.nats;

import com.intuit.karate.Json;
import io.nats.client.Connection;
import io.nats.client.Dispatcher;
import io.nats.client.Message;

import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * Fake "orders" service for the request/reply demo: subscribes to demo.orders.status and
 * synchronously replies with a canned order status, keyed by orderId - the NATS equivalent of
 * mock/users-api.feature, since Karate's MockServer only speaks HTTP and can't stand in for a
 * NATS responder. Package-private: only started/stopped by NatsLifecycle.
 */
class NatsResponder {

    private static final Map<String, String> ORDER_STATUSES = Map.of("ORD-1", "SHIPPED", "ORD-2", "PROCESSING");

    private final Connection connection;
    private final String subject;
    private Dispatcher dispatcher;

    NatsResponder(Connection connection, String subject) {
        this.connection = connection;
        this.subject = subject;
    }

    void start() {
        dispatcher = connection.createDispatcher(this::handle);
        dispatcher.subscribe(subject);
    }

    void stop() {
        if (dispatcher != null) {
            connection.closeDispatcher(dispatcher);
        }
    }

    private void handle(Message message) {
        String requestPayload = new String(message.getData(), StandardCharsets.UTF_8);
        String orderId = Json.of(requestPayload).get("orderId");
        String status = ORDER_STATUSES.getOrDefault(orderId, "NOT_FOUND");
        String reply = Json.object().set("orderId", orderId).set("status", status).toString();
        connection.publish(message.getReplyTo(), reply.getBytes(StandardCharsets.UTF_8));
    }
}
