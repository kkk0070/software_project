import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

// Check if email service is properly configured
const isEmailConfigured = () => {
  return !!(process.env.EMAIL_USER && process.env.EMAIL_PASSWORD);
};

// Create reusable transporter using SMTP or emailjs compatible service
const createTransporter = () => {
  // Check if using Gmail or custom SMTP
  if (process.env.EMAIL_SERVICE === 'gmail') {
    return nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
      },
      // Add timeouts to prevent hanging
      connectionTimeout: 5000, // 5 seconds connection timeout
      greetingTimeout: 5000,   // 5 seconds greeting timeout
      socketTimeout: 10000      // 10 seconds socket timeout
    });
  }
  
  // Default SMTP configuration (compatible with most email services including emailjs)
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: process.env.SMTP_PORT || 587,
    secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASSWORD
    },
    // Add timeouts to prevent hanging
    connectionTimeout: 5000, // 5 seconds connection timeout
    greetingTimeout: 5000,   // 5 seconds greeting timeout
    socketTimeout: 10000      // 10 seconds socket timeout
  });
};

/**
 * Send OTP email to user
 * @param {string} to - Recipient email address
 * @param {string} otp - One-time password
 * @param {string} userName - User's name
 * @returns {Promise<boolean>} - Success status
 */
export const sendOTPEmail = async (to, otp, userName = 'User') => {
  // Check if email is configured
  if (!isEmailConfigured()) {
    throw new Error('EMAIL_NOT_CONFIGURED');
  }

  try {
    const transporter = createTransporter();
    
    const mailOptions = {
      from: `"${process.env.EMAIL_FROM_NAME || 'SePro App'}" <${process.env.EMAIL_USER}>`,
      to: to,
      subject: 'Your Two-Factor Authentication Code',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body {
              font-family: Arial, sans-serif;
              line-height: 1.6;
              color: #333;
              max-width: 600px;
              margin: 0 auto;
              padding: 20px;
            }
            .header {
              background-color: #4CAF50;
              color: white;
              padding: 20px;
              text-align: center;
              border-radius: 5px 5px 0 0;
            }
            .content {
              background-color: #f9f9f9;
              padding: 30px;
              border-radius: 0 0 5px 5px;
            }
            .otp-code {
              background-color: #fff;
              border: 2px solid #4CAF50;
              padding: 20px;
              text-align: center;
              font-size: 32px;
              font-weight: bold;
              letter-spacing: 5px;
              margin: 20px 0;
              border-radius: 5px;
              color: #4CAF50;
            }
            .warning {
              background-color: #fff3cd;
              border-left: 4px solid #ffc107;
              padding: 15px;
              margin: 20px 0;
            }
            .footer {
              text-align: center;
              margin-top: 30px;
              color: #777;
              font-size: 12px;
            }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>Two-Factor Authentication</h1>
          </div>
          <div class="content">
            <h2>Hello ${userName}!</h2>
            <p>You have requested to enable Two-Factor Authentication on your account. Please use the following code to complete the verification:</p>
            
            <div class="otp-code">
              ${otp}
            </div>
            
            <p><strong>This code will expire in 10 minutes.</strong></p>
            
            <div class="warning">
              <strong>[WARNING] Security Notice:</strong>
              <ul>
                <li>Never share this code with anyone</li>
                <li>SePro staff will never ask for this code</li>
                <li>If you didn't request this code, please ignore this email</li>
              </ul>
            </div>
            
            <p>If you have any questions or concerns, please contact our support team.</p>
          </div>
          <div class="footer">
            <p>&copy; ${new Date().getFullYear()} SePro App. All rights reserved.</p>
          </div>
        </body>
        </html>
      `,
      text: `
Hello ${userName}!

You have requested to enable Two-Factor Authentication on your account.

Your verification code is: ${otp}

This code will expire in 10 minutes.

Security Notice:
- Never share this code with anyone
- SePro staff will never ask for this code
- If you didn't request this code, please ignore this email

If you have any questions or concerns, please contact our support team.

© ${new Date().getFullYear()} SePro App. All rights reserved.
      `
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('[SUCCESS] OTP email sent successfully:', info.messageId);
    return true;
  } catch (error) {
    // Provide more specific error messages
    if (error.code === 'ESOCKET' || error.code === 'ETIMEDOUT' || error.code === 'ECONNECTION') {
      throw new Error('EMAIL_CONNECTION_FAILED');
    } else if (error.code === 'EAUTH') {
      throw new Error('EMAIL_AUTH_FAILED');
    }
    
    console.error('[ERROR] Error sending OTP email:', error.message);
    throw new Error('EMAIL_SEND_FAILED');
  }
};

/**
 * Send 2FA status change notification
 * @param {string} to - Recipient email address
 * @param {string} userName - User's name
 * @param {boolean} enabled - Whether 2FA was enabled or disabled
 * @returns {Promise<boolean>} - Success status
 */
export const send2FAStatusEmail = async (to, userName, enabled) => {
  // Check if email is configured
  if (!isEmailConfigured()) {
    console.log('[WARNING]  Email not configured. Skipping 2FA status notification.');
    return false;
  }

  try {
    const transporter = createTransporter();
    
    const status = enabled ? 'Enabled' : 'Disabled';
    const statusColor = enabled ? '#4CAF50' : '#f44336';
    
    const mailOptions = {
      from: `"${process.env.EMAIL_FROM_NAME || 'SePro App'}" <${process.env.EMAIL_USER}>`,
      to: to,
      subject: `Two-Factor Authentication ${status}`,
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body {
              font-family: Arial, sans-serif;
              line-height: 1.6;
              color: #333;
              max-width: 600px;
              margin: 0 auto;
              padding: 20px;
            }
            .header {
              background-color: ${statusColor};
              color: white;
              padding: 20px;
              text-align: center;
              border-radius: 5px 5px 0 0;
            }
            .content {
              background-color: #f9f9f9;
              padding: 30px;
              border-radius: 0 0 5px 5px;
            }
            .footer {
              text-align: center;
              margin-top: 30px;
              color: #777;
              font-size: 12px;
            }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>Security Update</h1>
          </div>
          <div class="content">
            <h2>Hello ${userName}!</h2>
            <p>Two-Factor Authentication has been <strong>${status.toLowerCase()}</strong> on your account.</p>
            <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
            <p>${enabled ? 
              'Your account is now more secure. You will need to enter a verification code sent to your email when logging in.' : 
              'Your account no longer requires two-factor authentication for login.'
            }</p>
            <p>If you did not make this change, please contact our support team immediately.</p>
          </div>
          <div class="footer">
            <p>&copy; ${new Date().getFullYear()} SePro App. All rights reserved.</p>
          </div>
        </body>
        </html>
      `
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('[SUCCESS] 2FA status email sent successfully:', info.messageId);
    return true;
  } catch (error) {
    // Log specific error but don't throw (notification emails are non-critical)
    if (error.code === 'ESOCKET' || error.code === 'ETIMEDOUT' || error.code === 'ECONNECTION') {
      console.log('[WARNING]  Email service unreachable. Skipping 2FA status notification.');
    } else if (error.code === 'EAUTH') {
      console.log('[WARNING]  Email authentication failed. Check configuration.');
    } else {
      console.log('[WARNING]  Error sending 2FA status email:', error.message);
    }
    return false;
  }
};
