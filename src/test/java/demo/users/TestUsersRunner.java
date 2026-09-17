package demo.users;

import com.intuit.karate.junit5.Karate;
import org.junit.jupiter.api.extension.ExtendWith;
import support.MockServerLifecycle;

/**
 * Runs every *.feature file in this package (relativeTo) against the bundled mock API, which
 * MockServerLifecycle starts once for the whole test run before any scenario executes.
 */
@ExtendWith(MockServerLifecycle.class)
class TestUsersRunner {

    @Karate.Test
    Karate testUsers() {
        return Karate.run().relativeTo(getClass());
    }
}
