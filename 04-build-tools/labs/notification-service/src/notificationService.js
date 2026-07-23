/**
 * Core notification logic.
 * In a real system this would talk to an email or SMS provider.
 * Here it simulates sending, and keeps a count and a history.
 */

class NotificationService {
  constructor() {
    this.sentCount = 0;
    this.history = [];
  }

  async sendEmail({ to, subject, body }) {
    if (!to || !subject || !body) {
      throw new Error('Email requires to, subject, and body fields');
    }

    await this._simulate();

    const notification = {
      type: 'email',
      to,
      subject,
      sentAt: new Date().toISOString()
    };

    this.history.push(notification);
    this.sentCount++;

    console.log(`[EMAIL] To: ${to}`);
    console.log(`        Subject: ${subject}`);
    console.log(`        Status: sent`);
    return notification;
  }

  async sendSMS({ to, message }) {
    if (!to || !message) {
      throw new Error('SMS requires to and message fields');
    }

    await this._simulate();

    const notification = {
      type: 'sms',
      to,
      message,
      sentAt: new Date().toISOString()
    };

    this.history.push(notification);
    this.sentCount++;

    console.log(`[SMS]   To: ${to}`);
    console.log(`        Message: ${message}`);
    console.log(`        Status: sent`);
    return notification;
  }

  getSentCount() {
    return this.sentCount;
  }

  getHistory() {
    return [...this.history];
  }

  _simulate() {
    return new Promise(resolve => setTimeout(resolve, 50));
  }
}

module.exports = NotificationService;
