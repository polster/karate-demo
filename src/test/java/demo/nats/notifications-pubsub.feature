Feature: NATS pub/sub - notifications

Background:
  * def nats = Java.type('support.nats.NatsLifecycle').client()

@name=notifications-pubsub
Scenario: a subscriber receives a message published to a subject
  * def subject = 'demo.notifications.created'
  * def sub = nats.subscribe(subject)
  * def payload = '{"event":"user.created","userId":"u-1"}'
  When nats.publish(subject, payload)
  Then match sub.next(2000) == payload
