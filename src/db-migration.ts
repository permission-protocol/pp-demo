/**
 * Database Migration: Add webhook audit log table
 * Runs on production database — tracks all incoming webhook events
 */

import { Pool } from 'pg';

const PRODUCTION_DB_URL = process.env.DATABASE_URL;

interface MigrationResult {
  success: boolean;
  tablesCreated: string[];
  error?: string;
}

export async function runMigration(): Promise<MigrationResult> {
  const pool = new Pool({ connectionString: PRODUCTION_DB_URL });

  try {
    await pool.query('BEGIN');

    // Create audit log table for webhook events
    await pool.query(`
      CREATE TABLE IF NOT EXISTS webhook_audit_log (
        id SERIAL PRIMARY KEY,
        event_type VARCHAR(255) NOT NULL,
        source_ip INET NOT NULL,
        payload_hash VARCHAR(64) NOT NULL,
        signature_valid BOOLEAN NOT NULL,
        processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        raw_headers JSONB,
        response_code INTEGER
      );

      CREATE INDEX idx_webhook_audit_event_type
        ON webhook_audit_log (event_type);

      CREATE INDEX idx_webhook_audit_processed
        ON webhook_audit_log (processed_at DESC);
    `);

    // Alter existing webhooks table to add foreign key
    await pool.query(`
      ALTER TABLE webhooks
        ADD COLUMN IF NOT EXISTS last_audit_id INTEGER
        REFERENCES webhook_audit_log(id);
    `);

    await pool.query('COMMIT');

    return {
      success: true,
      tablesCreated: ['webhook_audit_log'],
    };
  } catch (error: any) {
    await pool.query('ROLLBACK');
    return {
      success: false,
      tablesCreated: [],
      error: error.message,
    };
  } finally {
    await pool.end();
  }
}
