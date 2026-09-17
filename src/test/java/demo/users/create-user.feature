@ignore
Feature: reusable helper - create a user
  Not a test in its own right (hence @ignore, so TestUsersRunner skips it during a normal run) -
  called from other features via `call read(...)` to seed a user as test setup, demonstrating
  Karate's feature-reuse idiom instead of duplicating the create-request boilerplate everywhere.

Background:
  * url baseUrl

Scenario:
  Given path '/users'
  And request { name: '#(name)', email: '#(email)' }
  When method post
  Then status 201
