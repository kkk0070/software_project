export default {
  // Use Node environment for testing
  testEnvironment: 'node',
  
  // Transform ES modules with babel-jest
  transform: {
    '^.+\\.js$': 'babel-jest',
  },
  
  // Test file patterns
  testMatch: [
    '**/tests/**/*.test.js',
    '**/tests/**/*.spec.js'
  ],
  
  // Coverage configuration
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/test/',
    '/config/'
  ],
  
  // Module file extensions
  moduleFileExtensions: ['js', 'json'],
  
  // Setup files
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  
  // Verbose output
  verbose: true,
  
  // Force exit after tests complete
  forceExit: true,
  
  // Clear mocks between tests
  clearMocks: true,
  
  // Detect open handles
  detectOpenHandles: true,
  
  // Timeout for tests
  testTimeout: 10000
};
