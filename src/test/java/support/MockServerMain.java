package support;

import com.intuit.karate.core.MockServer;

/**
 * Runs the bundled "users" mock API as a standalone, blocking process on a fixed port so it can
 * be pointed at by tools that run in their own JVM - namely Gatling, invoked separately via
 * {@code mvn gatling:test}. Not used by the functional test suite (see MockServerLifecycle),
 * which runs the mock in-process on a random port instead.
 *
 * Usage: mvn test-compile exec:java -Dmock.server.port=8080
 */
public class MockServerMain {

    public static void main(String[] args) throws InterruptedException {
        int port = Integer.getInteger("mock.server.port", 8080);
        MockServer server = MockServer
                .feature("classpath:mock/users-api.feature")
                .http(port)
                .build();
        System.out.println("mock 'users' API listening on http://localhost:" + server.getPort());
        Runtime.getRuntime().addShutdownHook(new Thread(server::stop));
        Thread.currentThread().join();
    }
}
