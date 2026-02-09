// Import database query builder (Knex) for PostgreSQL interactions
import { knex } from '../../config/database.js';
// Password hashing library for secure password storage
import bcrypt from 'bcrypt';
// JSON Web Token library for authentication tokens
import jwt from 'jsonwebtoken';
// File upload handling middleware
import multer from 'multer';
// Path utilities for file system operations
import path from 'path';
// File system operations
import fs from 'fs';
// ES module utilities for getting __dirname equivalent
import { fileURLToPath } from 'url';
import { dirname } from 'path';
// OTP (One-Time Password) utilities for 2FA
import { generateOTP, storeOTP, verifyOTP, generate2FASecret } from '../../utils/otpService.js';
// Email service for sending OTP and 2FA notifications
import { sendOTPEmail, send2FAStatusEmail } from '../../utils/emailService.js';

// Get current file path and directory (required for ES modules)
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Create directory for storing profile photos if it doesn't exist
const uploadsDir = path.join(__dirname, '../../uploads/profile-photos');
if (!fs.existsSync(uploadsDir)) {
  // Create directory recursively (including parent directories)
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer storage for profile photo uploads
const storage = multer.diskStorage({
  // Set destination directory for uploads
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  // Generate unique filename to prevent conflicts
  filename: (req, file, cb) => {
    // Create unique suffix using timestamp and random number
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    // Construct filename: profile-[timestamp]-[random].[extension]
    cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter to validate uploaded files are images only
const fileFilter = (req, file, cb) => {
  // Whitelist of allowed image MIME types
  const allowedMimetypes = ['image/jpeg', 'image/jpg', 'image/png'];
  
  // Check MIME type first (most reliable security check)
  if (!allowedMimetypes.includes(file.mimetype)) {
    return cb(new Error('Only JPG and PNG image files are allowed!'));
  }
  
  // Also check file extension as an additional security layer
  const ext = path.extname(file.originalname).toLowerCase();
  if (!['.jpg', '.jpeg', '.png'].includes(ext)) {
    return cb(new Error('Only .jpg, .jpeg and .png extensions are allowed!'));
  }
  
  // File passed validation, accept it
  cb(null, true);
};

export const uploadProfilePhoto = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: fileFilter
});

// Generate JWT token
const generateToken = (userId, email, role) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is not configured in environment variables');
  }
  
  return jwt.sign(
    { id: userId, email, role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRE || '24h' }
  );
};

// Register new user (signup)
export const signup = async (req, res) => {
  try {
    const {
      name, email, password, phone, location, role,
      vehicle_type, vehicle_model, license_plate, license_number, vehicle_year
    } = req.body;

    // Validate required fields
    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, email, and password are required'
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid email format'
      });
    }

    // Validate password length
    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long'
      });
    }

    // Check if email already exists
    const existingUser = await knex('users')
      .select('id')
      .where('email', email)
      .first();
      
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already registered'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Extract and display hash and salt for educational purposes
    // Bcrypt hash format: $2b$10$[22-char salt][31-char hash]
    const hashParts = hashedPassword.split('$');
    const algorithm = `$${hashParts[1]}$`;
    const costFactor = hashParts[2];
    const saltAndHash = hashParts[3];
    const salt = saltAndHash.substring(0, 22); // First 22 characters are the salt
    const hash = saltAndHash.substring(22);     // Remaining 31 characters are the hash
    
    console.log('\n[ENCRYPTING] Password Hashing Details (User Registration):');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`👤 User Email: ${email}`);
    console.log(`📝 Algorithm: ${algorithm} (bcrypt)`);
    console.log(`[INFO] Cost Factor: ${costFactor} rounds (2^${costFactor} = ${Math.pow(2, parseInt(costFactor))} iterations)`);
    console.log(`[INFO] Salt (22 chars): ${salt}`);
    console.log(`[INFO]  Hash (31 chars): ${hash}`);
    console.log(`[INFO] Full Hash: ${hashedPassword}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Insert user using Knex
    const [newUser] = await knex('users')
      .insert({
        name,
        email,
        password: hashedPassword,
        phone: phone || null,
        location: location || null,
        role: role || 'Rider'
      })
      .returning([
        'id', 'name', 'email', 'phone', 'location', 'role', 
        'status', 'verified', 'profile_setup_complete', 'rating', 
        'total_rides', 'created_at'
      ]);

    // If driver role, create driver record (even if vehicle details are not provided yet)
    // Vehicle details can be added later during profile setup or document upload
    if (role === 'Driver' || role === 'driver') {
      await knex('drivers').insert({
        user_id: newUser.id,
        vehicle_type: vehicle_type || null,
        vehicle_model: vehicle_model || null,
        license_plate: license_plate || null,
        license_number: license_number || null,
        vehicle_year: vehicle_year || null,
        earnings: 0.00,
        verification_status: 'Pending'
      });
    }

    // Generate JWT token
    const token = generateToken(newUser.id, newUser.email, newUser.role);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: newUser,
        token
      }
    });
  } catch (error) {
    console.error('Error during signup:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating user',
      error: error.message
    });
  }
};

// Login user
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required'
      });
    }

    // Find user by email with driver info using Knex
    const user = await knex('users as u')
      .select(
        'u.*',
        'd.vehicle_type', 'd.vehicle_model', 'd.license_plate', 'd.available',
        'd.license_number', 'd.vehicle_year', 'd.earnings', 'd.verification_status'
      )
      .leftJoin('drivers as d', 'u.id', 'd.user_id')
      .where('u.email', email)
      .first();

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Check if account is suspended
    if (user.status === 'Suspended') {
      return res.status(403).json({
        success: false,
        message: 'Account is suspended. Please contact support.'
      });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Check if 2FA is enabled
    if (user.two_factor_enabled) {
      // Generate and send OTP
      const otp = generateOTP();
      storeOTP(user.email, otp, 10);
      
      // Try to send OTP via email, but don't fail if email service is not configured
      try {
        await sendOTPEmail(user.email, otp, user.name);
      } catch (emailError) {
        // Provide helpful error messages based on the error type
        if (emailError.message === 'EMAIL_NOT_CONFIGURED') {
          console.log(`[WARNING] Email service not configured. OTP for ${user.email}: ${otp}`);
        } else if (emailError.message === 'EMAIL_CONNECTION_FAILED') {
          console.log(`[WARNING] Email service unreachable (network/firewall issue). OTP for ${user.email}: ${otp}`);
        } else if (emailError.message === 'EMAIL_AUTH_FAILED') {
          console.log(`[WARNING] Email authentication failed. Check EMAIL_USER and EMAIL_PASSWORD. OTP for ${user.email}: ${otp}`);
        } else {
          console.log(`[WARNING] Email service error. OTP for ${user.email}: ${otp}`);
        }
      }

      // Don't send token yet, require OTP verification
      return res.json({
        success: true,
        requires2FA: true,
        message: 'OTP sent to your email. Please verify to complete login.',
        data: {
          email: user.email.replace(/(.{2})(.*)(?=@)/, '$1***'), // Mask email
          userId: user.id
        }
      });
    }

    // Remove password from response
    delete user.password;

    // Generate JWT token
    const token = generateToken(user.id, user.email, user.role);

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user,
        token
      }
    });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({
      success: false,
      message: 'Error during login',
      error: error.message
    });
  }
};

// Verify OTP during login (2FA)
export const verifyLoginOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    // Validate required fields
    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Email and OTP are required'
      });
    }

    // Verify OTP
    const verification = verifyOTP(email, otp);
    
    if (!verification.success) {
      return res.status(400).json({
        success: false,
        message: verification.message
      });
    }

    // Get user details
    const user = await knex('users as u')
      .select(
        'u.*',
        'd.vehicle_type', 'd.vehicle_model', 'd.license_plate', 'd.available',
        'd.license_number', 'd.vehicle_year', 'd.earnings', 'd.verification_status'
      )
      .leftJoin('drivers as d', 'u.id', 'd.user_id')
      .where('u.email', email)
      .first();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Remove password from response
    delete user.password;

    // Generate JWT token
    const token = generateToken(user.id, user.email, user.role);

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user,
        token
      }
    });
  } catch (error) {
    console.error('Error verifying login OTP:', error);
    res.status(500).json({
      success: false,
      message: 'Error verifying OTP',
      error: error.message
    });
  }
};

// Get current user profile (protected route)
export const getProfile = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await knex('users')
      .select('u.id', 'u.name', 'u.email', 'u.phone', 'u.location', 'u.profile_photo', 
              'u.role', 'u.status', 'u.verified', 'u.profile_setup_complete', 
              'u.rating', 'u.total_rides', 'u.created_at', 'u.updated_at',
              'd.vehicle_type', 'd.vehicle_model', 'd.license_plate', 'd.available',
              'd.license_number', 'd.vehicle_year', 'd.earnings', 'd.verification_status')
      .from('users as u')
      .leftJoin('drivers as d', 'u.id', 'd.user_id')
      .where('u.id', userId)
      .first();

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching profile',
      error: error.message
    });
  }
};

// Update user profile (protected route)
export const updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, phone, location } = req.body;

    // Build update object dynamically
    const updates = {};
    
    if (name !== undefined) updates.name = name;
    if (phone !== undefined) updates.phone = phone;
    if (location !== undefined) updates.location = location;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    updates.updated_at = knex.fn.now();

    const [updatedUser] = await knex('users')
      .where('id', userId)
      .update(updates)
      .returning(['id', 'name', 'email', 'phone', 'location', 'role', 
                  'status', 'verified', 'rating', 'total_rides', 'updated_at']);

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: updatedUser
    });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating profile',
      error: error.message
    });
  }
};

// Mark profile setup as complete
export const completeProfileSetup = async (req, res) => {
  try {
    const userId = req.user.id;

    const [updatedUser] = await knex('users')
      .where('id', userId)
      .update({
        profile_setup_complete: true,
        updated_at: knex.fn.now()
      })
      .returning(['id', 'name', 'email', 'phone', 'location', 'role', 
                  'status', 'verified', 'profile_setup_complete', 
                  'rating', 'total_rides', 'updated_at']);

    res.json({
      success: true,
      message: 'Profile setup completed',
      data: updatedUser
    });
  } catch (error) {
    console.error('Error completing profile setup:', error);
    res.status(500).json({
      success: false,
      message: 'Error completing profile setup',
      error: error.message
    });
  }
};

// Request OTP for enabling 2FA
export const request2FAOTP = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user details
    const user = await knex('users')
      .select('id', 'name', 'email', 'two_factor_enabled')
      .where('id', userId)
      .first();
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Generate OTP
    const otp = generateOTP();
    
    // Store OTP with 10 minutes expiry
    storeOTP(user.email, otp, 10);

    // Try to send OTP via email, but don't fail if email service is not configured
    try {
      await sendOTPEmail(user.email, otp, user.name);
    } catch (emailError) {
      // Provide helpful error messages based on the error type
      if (emailError.message === 'EMAIL_NOT_CONFIGURED') {
        console.log(`[WARNING] Email service not configured. OTP for ${user.email}: ${otp}`);
      } else if (emailError.message === 'EMAIL_CONNECTION_FAILED') {
        console.log(`[WARNING] Email service unreachable (network/firewall issue). OTP for ${user.email}: ${otp}`);
      } else if (emailError.message === 'EMAIL_AUTH_FAILED') {
        console.log(`[WARNING] Email authentication failed. Check EMAIL_USER and EMAIL_PASSWORD. OTP for ${user.email}: ${otp}`);
      } else {
        console.log(`[WARNING] Email service error. OTP for ${user.email}: ${otp}`);
      }
    }

    // Mask email for privacy (handle short emails gracefully)
    const atIndex = user.email.indexOf('@');
    let maskedEmail = user.email;
    if (atIndex > 2) {
      maskedEmail = user.email.substring(0, 2) + '***' + user.email.substring(atIndex);
    } else if (atIndex > 0) {
      maskedEmail = user.email[0] + '***' + user.email.substring(atIndex);
    }

    res.json({
      success: true,
      message: 'OTP sent to your email address',
      data: {
        email: maskedEmail
      }
    });
  } catch (error) {
    console.error('Error requesting 2FA OTP:', error);
    
    // Check if this is a missing column error
    if (error.code === '42703' && error.message.includes('two_factor')) {
      return res.status(500).json({
        success: false,
        message: 'Database schema is outdated. Please run: npm run migrate-2fa',
        error: 'Missing 2FA columns in database. Migration required.',
        fixCommand: 'cd backend && npm run migrate-2fa'
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Error sending OTP',
      error: error.message
    });
  }
};

// Enable 2FA after OTP verification
export const enable2FA = async (req, res) => {
  try {
    const userId = req.user.id;
    const { otp } = req.body;

    if (!otp) {
      return res.status(400).json({
        success: false,
        message: 'OTP is required'
      });
    }

    // Get user details
    const user = await knex('users')
      .select('id', 'name', 'email', 'two_factor_enabled')
      .where('id', userId)
      .first();
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Verify OTP
    const verification = verifyOTP(user.email, otp);
    
    if (!verification.success) {
      return res.status(400).json({
        success: false,
        message: verification.message
      });
    }

    // Generate 2FA secret
    const twoFactorSecret = generate2FASecret();

    // Update user's 2FA status
    await knex('users')
      .where('id', userId)
      .update({
        two_factor_enabled: true,
        two_factor_secret: twoFactorSecret,
        updated_at: knex.fn.now()
      });

    // Try to send confirmation email, but don't fail if email service is not configured
    try {
      await send2FAStatusEmail(user.email, user.name, true);
    } catch (emailError) {
      console.error('Error sending 2FA status email (continuing anyway):', emailError);
    }

    res.json({
      success: true,
      message: 'Two-factor authentication enabled successfully',
      data: {
        two_factor_enabled: true
      }
    });
  } catch (error) {
    console.error('Error enabling 2FA:', error);
    
    // Check if this is a missing column error
    if (error.code === '42703' && error.message.includes('two_factor')) {
      return res.status(500).json({
        success: false,
        message: 'Database schema is outdated. Please run: npm run migrate-2fa',
        error: 'Missing 2FA columns in database. Migration required.',
        fixCommand: 'cd backend && npm run migrate-2fa'
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Error enabling two-factor authentication',
      error: error.message
    });
  }
};

// Disable 2FA
export const disable2FA = async (req, res) => {
  try {
    const userId = req.user.id;
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({
        success: false,
        message: 'Password is required to disable 2FA'
      });
    }

    // Get user details
    const user = await knex('users')
      .select('id', 'name', 'email', 'password', 'two_factor_enabled')
      .where('id', userId)
      .first();
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid password'
      });
    }

    // Update user's 2FA status
    await knex('users')
      .where('id', userId)
      .update({
        two_factor_enabled: false,
        two_factor_secret: null,
        updated_at: knex.fn.now()
      });

    // Send confirmation email
    await send2FAStatusEmail(user.email, user.name, false);

    res.json({
      success: true,
      message: 'Two-factor authentication disabled successfully',
      data: {
        two_factor_enabled: false
      }
    });
  } catch (error) {
    console.error('Error disabling 2FA:', error);
    
    // Check if this is a missing column error
    if (error.code === '42703' && error.message.includes('two_factor')) {
      return res.status(500).json({
        success: false,
        message: 'Database schema is outdated. Please run: npm run migrate-2fa',
        error: 'Missing 2FA columns in database. Migration required.',
        fixCommand: 'cd backend && npm run migrate-2fa'
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Error disabling two-factor authentication',
      error: error.message
    });
  }
};

// Get 2FA status
export const get2FAStatus = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await knex('users')
      .select('two_factor_enabled')
      .where('id', userId)
      .first();
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: {
        two_factor_enabled: user.two_factor_enabled || false
      }
    });
  } catch (error) {
    console.error('Error fetching 2FA status:', error);
    
    // Check if this is a missing column error
    if (error.code === '42703' && error.message.includes('two_factor')) {
      return res.status(500).json({
        success: false,
        message: 'Database schema is outdated. Please run: npm run migrate-2fa',
        error: 'Missing 2FA columns in database. Migration required.',
        fixCommand: 'cd backend && npm run migrate-2fa'
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Error fetching 2FA status',
      error: error.message
    });
  }
};

// Upload profile photo (protected route)
export const uploadPhoto = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    const userId = req.user.id;
    const photoUrl = `/uploads/profile-photos/${req.file.filename}`;

    // Delete old profile photo if exists
    const oldProfile = await knex('users')
      .select('profile_photo')
      .where('id', userId)
      .first();
      
    if (oldProfile?.profile_photo) {
      const oldPhotoPath = path.join(__dirname, '../..', oldProfile.profile_photo);
      if (fs.existsSync(oldPhotoPath)) {
        fs.unlinkSync(oldPhotoPath);
      }
    }

    // Update user profile with new photo URL
    const [updatedUser] = await knex('users')
      .where('id', userId)
      .update({
        profile_photo: photoUrl,
        updated_at: knex.fn.now()
      })
      .returning(['id', 'name', 'email', 'phone', 'location', 'profile_photo', 
                  'role', 'status', 'verified', 'rating', 'total_rides', 'updated_at']);

    res.json({
      success: true,
      message: 'Profile photo uploaded successfully',
      data: updatedUser
    });
  } catch (error) {
    console.error('Error uploading profile photo:', error);
    res.status(500).json({
      success: false,
      message: 'Error uploading profile photo',
      error: error.message
    });
  }
};
