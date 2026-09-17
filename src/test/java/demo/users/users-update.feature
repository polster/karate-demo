Feature: update user

Background:
  * url baseUrl
  * def created = call read('classpath:demo/users/create-user.feature') { name: 'Katherine Johnson', email: 'katherine@example.com' }
  * def user = created.response

Scenario: update user - happy path
  Given path '/users', user.id
  And request { name: 'Katherine G. Johnson', email: 'katherine@example.com' }
  When method put
  Then status 200
  And match response == { id: '#(user.id)', name: 'Katherine G. Johnson', email: 'katherine@example.com' }

Scenario: update user - not found
  Given path '/users', 'does-not-exist'
  And request { name: 'Nobody', email: 'nobody@example.com' }
  When method put
  Then status 404
