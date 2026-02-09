#!/usr/bin/env node
/**
 * Test that keyManagement handles missing table gracefully
 */

import { initializeKeyManagement } from '../src/utils/keyManagement.js';

console.log('Testing keyManagement error handling...\n');

// Test the error handling when table doesn't exist
try {
  const result = await initializeKeyManagement();
  
  if (result === null) {
    console.log('[SUCCESS] TEST PASSED: Function returns null when table doesn\'t exist');
    console.log('   This is the expected behavior - server should start successfully');
    process.exit(0);
  } else {
    console.log('[SUCCESS] TEST PASSED: Keys were initialized (table exists)');
    console.log('   Result:', result);
    process.exit(0);
  }
} catch (error) {
  console.error('[ERROR] TEST FAILED: Function threw an error');
  console.error('   Error:', error.message);
  console.error('   The server would crash on startup with this error');
  process.exit(1);
}
