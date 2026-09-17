Feature: NATS request/reply - order status

Background:
  * def nats = Java.type('support.nats.NatsLifecycle').client()

@name=orders-request-reply
Scenario: request the status of a known order and receive a synchronous reply
  * def reply = nats.request('demo.orders.status', '{"orderId":"ORD-1"}', 2000)
  * match reply == '#present'
  * match karate.fromString(reply) == { orderId: 'ORD-1', status: 'SHIPPED' }

Scenario: request the status of an unknown order and receive a not-found reply
  * def reply = nats.request('demo.orders.status', '{"orderId":"does-not-exist"}', 2000)
  * match karate.fromString(reply) == { orderId: 'does-not-exist', status: 'NOT_FOUND' }
