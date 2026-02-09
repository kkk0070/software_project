import bcrypt from 'bcrypt';

const passwords = {
  'admin123': 'Admin password',
  'password123': 'Default password for sample users'
};

async function generateHashes() {
  console.log('Generating bcrypt hashes for default passwords:\n');
  
  for (const [password, description] of Object.entries(passwords)) {
    const hash = await bcrypt.hash(password, 10);
    console.log(`${description}:`);
    console.log(`Password: ${password}`);
    console.log(`Hash: ${hash}\n`);
  }
}

// Only run if this file is executed directly (not imported)
if (import.meta.url === `file://${process.argv[1]}`) {
  generateHashes().catch(console.error);
}

export { generateHashes };
