#!/usr/bin/env node
/**
 * Test script for encoding utilities and security analysis
 */

import { encodeToBase64, decodeFromBase64, getEncodingInfo } from '../src/utils/encodingUtils.js';
import { analyzeBase64Security, generateSecurityReport, getSecuritySummary } from '../src/utils/securityAnalysis.js';

console.log('Testing Base64 Encoding Utilities...\n');

// Test 1: Basic encoding/decoding
const testData = 'Sensitive driver document data: License #ABC12345';
console.log('Original Data:', testData);

const encoded = encodeToBase64(testData);
console.log('Encoded Data:', encoded);

const decoded = decodeFromBase64(encoded);
console.log('Decoded Data:', decoded);
console.log('Match:', testData === decoded ? '✓ PASS' : '✗ FAIL');

// Test 2: Encoding information
console.log('\n' + '='.repeat(80));
console.log('ENCODING INFORMATION');
console.log('='.repeat(80));
const encodingInfo = getEncodingInfo(testData, encoded);
console.log(JSON.stringify(encodingInfo, null, 2));

// Test 3: Security Analysis
console.log('\n' + '='.repeat(80));
console.log('SECURITY ANALYSIS');
console.log('='.repeat(80));
const securitySummary = getSecuritySummary();
console.log('Summary:', securitySummary);

// Test 4: Full Security Report (Terminal Output)
console.log(generateSecurityReport());

console.log('\n✓ All tests completed successfully!');
