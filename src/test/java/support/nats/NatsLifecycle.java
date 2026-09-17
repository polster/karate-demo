package support.nats;

import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

/**
 * Opens one shared NATS connection for the whole test run and starts the fake "orders"
 * responder (NatsResponder) needed for the request/reply demo, using the same JUnit5 "singleton
 * resource" pattern as MockServerLifecycle. Unlike the HTTP mock, there is no in-process
 * fallback - jnats is a client library only, so a NATS server (started via
 * scripts/nats-start.sh / docker-compose.nats.yml) must already be reachable.
 */
public class NatsLifecycle implements BeforeAllCallback {

    private static final ExtensionContext.Namespace NAMESPACE = ExtensionContext.Namespace.create(NatsLifecycle.class);
    private static final String KEY = "natsConnection";
    private static volatile NatsClient CLIENT;

    @Override
    public void beforeAll(ExtensionContext context) {
        context.getRoot().getStore(NAMESPACE).getOrComputeIfAbsent(KEY, key -> start());
    }

    /** Used by feature Backgrounds: Java.type('support.nats.NatsLifecycle').client() */
    public static NatsClient client() {
        if (CLIENT == null) {
            throw new IllegalStateException("NatsLifecycle has not started yet - is @ExtendWith(NatsLifecycle.class) applied to the runner?");
        }
        return CLIENT;
    }

    private static Resource start() {
        String url = System.getProperty("nats.server.url", "nats://localhost:4222");
        try {
            CLIENT = NatsClient.connect(url);
        } catch (Exception e) {
            throw new RuntimeException("could not connect to NATS at " + url + " - is it running? (see scripts/nats-start.sh / make nats-start)", e);
        }
        NatsResponder responder = new NatsResponder(CLIENT.raw(), "demo.orders.status");
        responder.start();
        return new Resource(CLIENT, responder);
    }

    private static final class Resource implements ExtensionContext.Store.CloseableResource {
        private final NatsClient client;
        private final NatsResponder responder;

        Resource(NatsClient client, NatsResponder responder) {
            this.client = client;
            this.responder = responder;
        }

        @Override
        public void close() throws Exception {
            responder.stop();
            client.close();
            CLIENT = null;
        }
    }
}
