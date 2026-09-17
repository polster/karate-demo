package support.nats;

import io.nats.client.Connection;
import io.nats.client.Message;
import io.nats.client.Nats;
import io.nats.client.Options;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.concurrent.TimeoutException;

/**
 * Thin synchronous facade over the NATS Java client (jnats), so demo/nats/*.feature files can
 * drive NATS through Karate's Java interop (Java.type(...)) with plain String payloads, instead
 * of juggling raw Connection/Message/Subscription objects and byte[] in feature files. One
 * instance wraps one live connection; see NatsLifecycle for how it's shared across the whole
 * functional test run.
 */
public class NatsClient {

    private final Connection connection;

    private NatsClient(Connection connection) {
        this.connection = connection;
    }

    public static NatsClient connect(String url) throws IOException, InterruptedException {
        Options options = new Options.Builder().server(url).connectionTimeout(Duration.ofSeconds(5)).build();
        return new NatsClient(Nats.connect(options));
    }

    public void publish(String subject, String payload) {
        connection.publish(subject, payload.getBytes(StandardCharsets.UTF_8));
    }

    // registers the subscription and flushes the connection before returning, so a publish()
    // that immediately follows is guaranteed to reach a subscriber that's already registered on
    // the server - core NATS pub/sub has no message queueing for late subscribers.
    public NatsSubscription subscribe(String subject) throws TimeoutException, InterruptedException {
        io.nats.client.Subscription subscription = connection.subscribe(subject);
        connection.flush(Duration.ofSeconds(2));
        return new NatsSubscription(subscription);
    }

    public String request(String subject, String payload, long timeoutMs) throws InterruptedException {
        Message reply = connection.request(subject, payload.getBytes(StandardCharsets.UTF_8), Duration.ofMillis(timeoutMs));
        return reply == null ? null : new String(reply.getData(), StandardCharsets.UTF_8);
    }

    public void close() throws InterruptedException {
        connection.close();
    }

    Connection raw() {
        return connection;
    }
}
