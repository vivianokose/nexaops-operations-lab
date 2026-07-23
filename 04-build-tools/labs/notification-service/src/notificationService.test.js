/**
 * Checks that NotificationService behaves correctly.
 * Uses Node's own built-in test runner, no extra tools needed.
 */

const { test } = require('node:test');
const assert = require('node:assert');
const NotificationService = require('./notificationService');

test('sendEmail increments the sent count', async () => {
  const service = new NotificationService();
  await service.sendEmail({ to: 'test@nexaops.com', subject: 'Test', body: 'Body' });
  assert.strictEqual(service.getSentCount(), 1);
});

test('sendSMS increments the sent count', async () => {
  const service = new NotificationService();
  await service.sendSMS({ to: '+234801234567', message: 'Test alert' });
  assert.strictEqual(service.getSentCount(), 1);
});

test('sending both email and SMS counts correctly', async () => {
  const service = new NotificationService();
  await service.sendEmail({ to: 'a@b.com', subject: 'Hi', body: 'Hello' });
  await service.sendSMS({ to: '+1234', message: 'Alert' });
  assert.strictEqual(service.getSentCount(), 2);
});

test('sendEmail throws when fields are missing', async () => {
  const service = new NotificationService();
  await assert.rejects(
    () => service.sendEmail({ to: 'a@b.com' }),
    /Email requires to, subject, and body fields/
  );
});

test('getHistory returns what was sent', async () => {
  const service = new NotificationService();
  await service.sendEmail({ to: 'a@b.com', subject: 'Hi', body: 'Hello' });
  const history = service.getHistory();
  assert.strictEqual(history.length, 1);
  assert.strictEqual(history[0].type, 'email');
});
