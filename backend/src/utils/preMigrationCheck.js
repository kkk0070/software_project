#!/usr/bin/env node
/**
 * Pre-Migration Checklist
 * Verifies all prerequisites before running database migrations
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

console.log('\n' + '═'.repeat(80));
console.log('                PRE-MIGRATION CHECKLIST');
console.log('═'.repeat(80) + '\n');

let allChecksPassed = true;

// Check 1: Node.js version
console.log('1. Checking Node.js version...');
const nodeVersion = process.version;
const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
if (majorVersion >= 16) {
  console.log(`   [SUCCESS] Node.js ${nodeVersion} (Required: >= 16.x)`);
} else {
  console.log(`   [ERROR] Node.js ${nodeVersion} - Please upgrade to >= 16.x`);
  allChecksPassed = false;
}

// Check 2: package.json exists
console.log('\n2. Checking package.json...');
const packageJsonPath = path.join(__dirname, '../../package.json');
if (fs.existsSync(packageJsonPath)) {
  console.log('   [SUCCESS] package.json found');
} else {
  console.log('   [ERROR] package.json not found');
  allChecksPassed = false;
}

// Check 3: node_modules exists
console.log('\n3. Checking dependencies installation...');
const nodeModulesPath = path.join(__dirname, '../../node_modules');
if (fs.existsSync(nodeModulesPath)) {
  console.log('   [SUCCESS] node_modules directory exists');
  
  // Check for critical dependencies
  const criticalPackages = ['pg', 'dotenv', 'express'];
  let missingPackages = [];
  
  for (const pkg of criticalPackages) {
    const pkgPath = path.join(nodeModulesPath, pkg);
    if (!fs.existsSync(pkgPath)) {
      missingPackages.push(pkg);
    }
  }
  
  if (missingPackages.length > 0) {
    console.log(`   [ERROR] Missing packages: ${missingPackages.join(', ')}`);
    console.log('   → Run: npm install');
    allChecksPassed = false;
  } else {
    console.log('   [SUCCESS] Critical packages installed (pg, dotenv, express)');
  }
} else {
  console.log('   [ERROR] node_modules not found');
  console.log('   → Run: npm install');
  allChecksPassed = false;
}

// Check 4: .env file exists
console.log('\n4. Checking environment configuration...');
const envPath = path.join(__dirname, '../../.env');
const envExamplePath = path.join(__dirname, '../../.env.example');

if (fs.existsSync(envPath)) {
  console.log('   [SUCCESS] .env file exists');
  
  // Read and check for critical variables
  try {
    const envContent = fs.readFileSync(envPath, 'utf-8');
    const hasDbConfig = envContent.includes('DB_HOST') || 
                        envContent.includes('DB_NAME') ||
                        envContent.includes('DB_USER');
    
    if (hasDbConfig) {
      console.log('   [SUCCESS] Database configuration found in .env');
    } else {
      console.log('   [WARNING]  .env exists but may be missing database configuration');
      console.log('   → Check: DB_HOST, DB_NAME, DB_USER, DB_PASSWORD');
    }
  } catch (err) {
    console.log('   [WARNING]  Could not read .env file');
  }
} else {
  console.log('   [ERROR] .env file not found');
  if (fs.existsSync(envExamplePath)) {
    console.log('   → Run: cp .env.example .env');
    console.log('   → Then edit .env with your database settings');
  } else {
    console.log('   → Create .env file with database configuration');
  }
  allChecksPassed = false;
}

// Check 5: Try to load database module
console.log('\n5. Checking database module...');
try {
  // Just check if we can resolve the module
  const dbModulePath = path.join(__dirname, '../config/database.js');
  if (fs.existsSync(dbModulePath)) {
    console.log('   [SUCCESS] Database module exists');
  } else {
    console.log('   [ERROR] Database module not found');
    allChecksPassed = false;
  }
} catch (err) {
  console.log('   [ERROR] Error checking database module:', err.message);
  allChecksPassed = false;
}

// Check 6: PostgreSQL connection (optional - will be tested during migration)
console.log('\n6. PostgreSQL connection check...');
console.log('   [INFO]  Will be verified when migration runs');
console.log('   → Ensure PostgreSQL is running');
console.log('   → Database must exist (create with: createdb ecoride_db)');

// Summary
console.log('\n' + '═'.repeat(80));
if (allChecksPassed) {
  console.log('[SUCCESS] ALL CHECKS PASSED - Ready to run migration!');
  console.log('═'.repeat(80) + '\n');
  console.log('Next steps:');
  console.log('  1. Ensure PostgreSQL is running');
  console.log('  2. Create database if needed: createdb -U postgres ecoride_db');
  console.log('  3. Run: npm run init-db (if first time)');
  console.log('  4. Run: npm run migrate-encryption');
  console.log('');
  process.exit(0);
} else {
  console.log('[ERROR] CHECKS FAILED - Please fix the issues above');
  console.log('═'.repeat(80) + '\n');
  console.log('Quick fix:');
  console.log('  1. Run: npm install');
  console.log('  2. Create .env: cp .env.example .env');
  console.log('  3. Edit .env with your database settings');
  console.log('  4. Run this check again: node src/utils/preMigrationCheck.js');
  console.log('');
  process.exit(1);
}
