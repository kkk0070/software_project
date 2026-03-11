import dotenv from 'dotenv';
dotenv.config();

const knexConfig = {
  client: 'pg',
  connection: (process.env.DATABASE_URL || process.env.POSTGRES_URL)
    ? {
      connectionString: process.env.DATABASE_URL || process.env.POSTGRES_URL,
      ssl: { rejectUnauthorized: false }
    }
    : {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'ecoride_db',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD,
    },
  pool: {
    min: 0,
    max: (process.env.VERCEL === '1') ? 5 : 20,
    idleTimeoutMillis: 30000,
    acquireTimeoutMillis: 10000,
  },
  debug: process.env.NODE_ENV === 'development',
};

export default knexConfig;
