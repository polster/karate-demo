package demo.nats;

import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.extension.ExtendWith;
import support.nats.NatsLifecycle;

/**
 * Runs every *.feature file in this package (relativeTo) against a real NATS server, which
 * NatsLifecycle connects to once for the whole test run before any scenario executes. Unlike
 * TestUsersRunner there is no in-process fallback, so this is excluded from plain `mvn test`
 * (see the maven-surefire-plugin includes in pom.xml) and run explicitly via `make test-nats`.
 */
@ExtendWith(NatsLifecycle.class)
class TestNatsRunner {

    @Karate.Test
    Karate testNats() {
        return Karate.run().relativeTo(getClass());
    }
}
