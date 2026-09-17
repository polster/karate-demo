Feature: create user

Background:
  * url baseUrl

@name=create-happy-path
Scenario: create a user - happy path
  * def user = { name: 'Ada Lovelace', email: 'ada@example.com' }
  Given path '/users'
  And request user
  When method post
  Then status 201
  And match response == { id: '#string', name: '#(user.name)', email: '#(user.email)' }

# data-driven "configuration through parameters": every row below is the same validation
# scenario replayed against a different payload, including one read from an external fixture
Scenario Outline: reject an invalid payload - <description>
  Given path '/users'
  And request <payload>
  When method post
  Then status 400
  And match response == { message: 'name and email are required fields' }

  Examples:
    | description               | payload                                                            |
    | missing email field       | { "name": "Grace Hopper" }                                         |
    | missing name field        | { "email": "grace@example.com" }                                   |
    | empty payload             | {}                                                                  |
    | blank name (from fixture) | read('classpath:demo/users/fixtures/invalid-user.json')            |
