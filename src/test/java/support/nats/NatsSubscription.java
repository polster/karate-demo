package support.nats;

import io.nats.client.Message;
import io.nats.client.Subscription;

import java.nio.charset.StandardCharsets;
import java.time.Duration;

/** Thin wrapper around a synchronous NATS Subscription, returned by NatsClient.subscribe(). */
public class NatsSubscription {

    private final Subscription subscription;

    NatsSubscription(Subscription subscription) {
        this.subscription = subscription;
    }

    /** Blocks up to timeoutMs for the next message; returns null if none arrives in time. */
    public String next(long timeoutMs) throws InterruptedException {
        Message message = subscription.nextMessage(Duration.ofMillis(timeoutMs));
        return message == null ? null : new String(message.getData(), StandardCharsets.UTF_8);
    }

    public void close() {
        subscription.unsubscribe();
    }
}
