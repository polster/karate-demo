Feature: delete user

Background:
  * url baseUrl
  * def created = call read('classpath:demo/users/create-user.feature') { name: 'Margaret Hamilton', email: 'margaret@example.com' }
  * def user = created.response

Scenario: delete user then confirm it is gone
  Given path '/users', user.id
  When method delete
  Then status 204

  Given path '/users', user.id
  When method get
  Then status 404

Scenario: delete unknown user returns 404
  Given path '/users', 'does-not-exist'
  When method delete
  Then status 404
