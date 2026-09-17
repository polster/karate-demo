Feature: mock API for the "users" resource

  This feature file *is* the bundled demo API - a small in-memory, non-persistent
  CRUD service for a "users" resource. It is started as a Karate MockServer:
    - for functional tests, by support/MockServerLifecycle.java (one instance per test run)
    - for the load test, by support/MockServerMain.java (a standalone process)
  There is no separate application to build or deploy - the mock *is* the service under test.

  Background state (users) is set up once when the mock starts and shared by every request
  afterwards. Ids are UUIDs rather than an incrementing counter so that concurrent creates
  (as happen under the Gatling load test) never race on a shared read-modify-write counter.

Background:
  * def UUID = Java.type('java.util.UUID')
  * def users = {}

Scenario: pathMatches('/users') && methodIs('post') && (!request.name || !request.email)
  * def responseStatus = 400
  * def response = { message: 'name and email are required fields' }

Scenario: pathMatches('/users') && methodIs('post')
  * def user = request
  * eval user.id = '' + UUID.randomUUID()
  * eval users[user.id] = user
  * def responseStatus = 201
  * def response = user

Scenario: pathMatches('/users') && methodIs('get')
  * def responseStatus = 200
  * def response = Object.values(users)

Scenario: pathMatches('/users/{id}') && methodIs('get')
  * def found = users[pathParams.id]
  * def responseStatus = found ? 200 : 404
  * def response = found ? found : { message: 'user ' + pathParams.id + ' not found' }

Scenario: pathMatches('/users/{id}') && methodIs('put')
  * def found = users[pathParams.id] != null
  * def responseStatus = found ? 200 : 404
  * def updated = request
  * eval if (found) updated.id = pathParams.id
  * eval if (found) users[pathParams.id] = updated
  * def response = found ? updated : { message: 'user ' + pathParams.id + ' not found' }

Scenario: pathMatches('/users/{id}') && methodIs('delete')
  * def found = users[pathParams.id] != null
  * def responseStatus = found ? 204 : 404
  * eval delete users[pathParams.id]
