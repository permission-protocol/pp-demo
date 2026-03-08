#!/usr/bin/env node
/**
 * validate-messages.js
 * 
 * Validates outreach message payloads before Expandi injection.
 * Expandi silently drops placeholders >300 chars — this catches them BEFORE injection.
 * 
 * Usage:
 *   node validate-messages.js <leads.json>
 *   node validate-messages.js --stdin  (reads JSON from stdin)
 * 
 * Also usable as a module:
 *   const { validateLeads } = require('./validate-messages');
 */

const EXPANDI_PLACEHOLDER_LIMIT = 300;
const FIELDS_TO_CHECK = ['message_1', 'followup_1', 'followup_2', 'connection_note', 'connection_note_short'];

function validateLead(lead) {
  const issues = [];
  const warnings = [];

  for (const field of FIELDS_TO_CHECK) {
    if (lead[field] !== undefined) {
      const len = lead[field].length;
      if (len > EXPANDI_PLACEHOLDER_LIMIT) {
        issues.push({
          field,
          length: len,
          over: len - EXPANDI_PLACEHOLDER_LIMIT,
          preview: lead[field].substring(0, 60) + '...',
        });
      } else if (len > 250) {
        // Warning zone: close to limit
        warnings.push({ field, length: len, remaining: EXPANDI_PLACEHOLDER_LIMIT - len });
      }
    }
  }

  return { issues, warnings };
}

function validateLeads(leads) {
  const results = [];
  let totalErrors = 0;
  let totalWarnings = 0;

  for (const lead of leads) {
    const name = lead.name || lead.first_name || lead.linkedin_url || '(unknown)';
    const { issues, warnings } = validateLead(lead);
    totalErrors += issues.length;
    totalWarnings += warnings.length;
    results.push({ name, issues, warnings });
  }

  return { results, totalErrors, totalWarnings };
}

function printReport(leads) {
  const { results, totalErrors, totalWarnings } = validateLeads(leads);

  console.log('\n=== Expandi Placeholder Validation ===\n');

  for (const { name, issues, warnings } of results) {
    if (issues.length === 0 && warnings.length === 0) {
      console.log(`  ✅ ${name} — all fields OK`);
    } else {
      if (issues.length > 0) {
        console.log(`  ❌ ${name} — ${issues.length} field(s) too long:`);
        for (const { field, length, over, preview } of issues) {
          console.log(`     └─ ${field}: ${length} chars (+${over} over limit)`);
          console.log(`        "${preview}"`);
        }
      }
      if (warnings.length > 0) {
        console.log(`  ⚠️  ${name} — ${warnings.length} field(s) near limit:`);
        for (const { field, length, remaining } of warnings) {
          console.log(`     └─ ${field}: ${length} chars (${remaining} remaining)`);
        }
      }
    }
  }

  console.log('\n--- Summary ---');
  console.log(`  Total leads: ${leads.length}`);
  console.log(`  Errors (will be dropped): ${totalErrors}`);
  console.log(`  Warnings (near limit): ${totalWarnings}`);

  if (totalErrors > 0) {
    console.log('\n❌ VALIDATION FAILED — fix the above before injecting into Expandi\n');
    process.exit(1);
  } else {
    console.log('\n✅ All leads safe to inject\n');
  }
}

// CLI
if (require.main === module) {
  let input = '';

  if (process.argv.includes('--stdin')) {
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', chunk => input += chunk);
    process.stdin.on('end', () => {
      const leads = JSON.parse(input);
      printReport(Array.isArray(leads) ? leads : [leads]);
    });
  } else if (process.argv[2]) {
    const fs = require('fs');
    const leads = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
    printReport(Array.isArray(leads) ? leads : [leads]);
  } else {
    console.error('Usage: node validate-messages.js <leads.json>');
    console.error('       node validate-messages.js --stdin');
    process.exit(1);
  }
}

module.exports = { validateLeads, validateLead, EXPANDI_PLACEHOLDER_LIMIT };
