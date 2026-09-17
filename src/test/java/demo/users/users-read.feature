Feature: read user

Background:
  * url baseUrl
  * def created = call read('classpath:demo/users/create-user.feature') { name: 'Alan Turing', email: 'alan@example.com' }
  * def user = created.response

@name=get-happy-path
Scenario: get user by id - happy path
  Given path '/users', user.id
  When method get
  Then status 200
  And match response == user

Scenario: get user by id - not found
  Given path '/users', 'does-not-exist'
  When method get
  Then status 404
  And match response == { message: 'user does-not-exist not found' }

Scenario: list users includes the created user
  Given path '/users'
  When method get
  Then status 200
  And match response contains user
