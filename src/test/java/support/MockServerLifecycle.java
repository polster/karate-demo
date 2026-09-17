package support;

import com.intuit.karate.core.MockServer;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

/**
 * Starts the bundled "users" mock API once per test JVM (on a random free port) and stops it
 * when the whole test run finishes, using the JUnit5 "singleton resource" pattern:
 * {@link ExtensionContext.Store} entries scoped to the root context are only closed at the
 * very end of the run, regardless of how many runner classes apply this extension.
 *
 * If {@code mock.server.url} is already set (e.g. by scripts/functional-test.sh, pointing at
 * the mock API's Docker Compose container on a fixed port), that instance is reused instead -
 * this class only falls back to starting its own in-process instance when running via plain
 * {@code mvn test}, with no external mock available.
 */
public class MockServerLifecycle implements BeforeAllCallback {

    private static final ExtensionContext.Namespace NAMESPACE = ExtensionContext.Namespace.create(MockServerLifecycle.class);
    private static final String KEY = "usersMockServer";

    @Override
    public void beforeAll(ExtensionContext context) {
        context.getRoot().getStore(NAMESPACE).getOrComputeIfAbsent(KEY, key -> start());
    }

    private static Resource start() {
        String externalUrl = System.getProperty("mock.server.url");
        if (externalUrl != null && !externalUrl.isBlank()) {
            return new Resource(null);
        }
        MockServer server = MockServer
                .feature("classpath:mock/users-api.feature")
                .http(0)
                .build();
        System.setProperty("mock.server.url", "http://localhost:" + server.getPort());
        return new Resource(server);
    }

    private static final class Resource implements ExtensionContext.Store.CloseableResource {

        private final MockServer server;

        private Resource(MockServer server) {
            this.server = server;
        }

        @Override
        public void close() {
            if (server != null) {
                server.stop();
            }
        }
    }
}
