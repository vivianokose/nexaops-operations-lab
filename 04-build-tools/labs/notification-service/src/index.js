/**
 * NexaOps Notification Service v1.0.0
 * Entry point: this is the file that runs when you start the service.
 */

const NotificationService = require('./notificationService');

const service = new NotificationService();

async function main() {
  console.log('=== NexaOps Notification Service v1.0.0 ===');
  console.log('Initialising...\n');

  await service.sendEmail({
    to: 'ops-team@nexaops.com',
    subject: 'Service health check passed',
    body: 'All systems operational as of ' + new Date().toUTCString()
  });

  await service.sendSMS({
    to: '+2348012345678',
    message: 'NexaOps alert: Deployment completed successfully'
  });

  console.log('\nNotification queue processed.');
  console.log(`Total notifications sent: ${service.getSentCount()}`);
}

main().catch(console.error);
