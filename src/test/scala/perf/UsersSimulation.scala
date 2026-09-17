package perf

import com.intuit.karate.gatling.PreDef._
import io.gatling.core.Predef._

import scala.concurrent.duration._

/**
 * Load-tests the "users" mock API by replaying the same *.feature files exercised by the
 * functional test suite (see demo/users) - Karate's headline benefit for load testing: the
 * scenarios are defined once and reused as-is, with no separate load-test scripting.
 *
 * Run with: mvn test-compile gatling:test
 * (the mock API must already be running - see support/MockServerMain, or README.md)
 *
 * The load profile is configurable via system properties so a CI workflow_dispatch input
 * can control it without touching this file, e.g.:
 *   mvn test-compile gatling:test -Dgatling.users=50 -Dgatling.rampSeconds=20
 */
class UsersSimulation extends Simulation {

  val userCount: Int = Integer.getInteger("gatling.users", 20)
  val rampSeconds: Int = Integer.getInteger("gatling.rampSeconds", 10)

  val protocol = karateProtocol(
    "/users" -> Nil,
    "/users/{id}" -> Nil
  )

  protocol.runner.karateEnv("load")

  val createUser = scenario("create user")
    .exec(karateFeature("classpath:demo/users/users-create.feature@name=create-happy-path"))

  val readUser = scenario("read user")
    .exec(karateFeature("classpath:demo/users/users-read.feature@name=get-happy-path"))

  setUp(
    createUser.inject(rampUsers(userCount) during (rampSeconds seconds)).protocols(protocol),
    readUser.inject(rampUsers(userCount) during (rampSeconds seconds)).protocols(protocol)
  ).assertions(
    global.successfulRequests.percent.gte(95),
    global.responseTime.max.lt(2000)
  )
}
