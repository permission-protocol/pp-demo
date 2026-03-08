-- PP Outreach Engine — SQLite Schema
-- Deploy: sqlite3 /opt/pp-outreach/db/outreach.sqlite < schema.sql

CREATE TABLE IF NOT EXISTS signals (
  id TEXT PRIMARY KEY,                    -- sig_YYYYMMDD_NNN
  type TEXT NOT NULL,                     -- production_incident, funding, hiring, regulatory, public_complaint, launch
  source TEXT NOT NULL,                   -- hn, twitter, github, news, article
  company TEXT NOT NULL,
  summary TEXT NOT NULL,
  url TEXT,
  urgency TEXT DEFAULT 'warm',            -- hot, warm, cold
  detected_at TEXT NOT NULL,              -- ISO 8601
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS targets (
  id TEXT PRIMARY KEY,                    -- tgt_YYYYMMDD_NNN
  signal_id TEXT REFERENCES signals(id),
  name TEXT NOT NULL,
  title TEXT,
  company TEXT NOT NULL,
  linkedin_url TEXT NOT NULL,
  segment TEXT,                           -- founder, cto, vp_eng, devops_lead, head_of_security, researcher
  email TEXT,
  twitter TEXT,
  enriched_at TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS outreach (
  id TEXT PRIMARY KEY,                    -- out_YYYYMMDD_NNN
  target_id TEXT NOT NULL REFERENCES targets(id),
  signal_id TEXT REFERENCES signals(id),
  connection_note TEXT NOT NULL,
  message_1 TEXT NOT NULL,
  followup_1 TEXT,
  followup_2 TEXT,
  angle TEXT NOT NULL,                    -- incident_response, deploy_safety, accountability_gap, their_own_words
  opener TEXT NOT NULL,                   -- pain_point, social_proof, curiosity, peer
  tone TEXT DEFAULT 'peer_founder',
  expandi_campaign_id TEXT,
  injected_at TEXT,                       -- when pushed to Expandi
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  outreach_id TEXT REFERENCES outreach(id),
  target_id TEXT REFERENCES targets(id),
  event_type TEXT NOT NULL,               -- connection_sent, connection_accepted, message_sent, replied, replied_first, disconnected, campaign_finished
  reply_text TEXT,                        -- captured from webhook payload if reply event
  reply_classification TEXT,              -- positive, neutral, negative, meeting
  expandi_data TEXT,                      -- raw JSON from webhook
  timestamp TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS playbook_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  version INTEGER NOT NULL,
  changes TEXT NOT NULL,                  -- JSON: what changed and why
  metrics TEXT,                           -- JSON: win rates at time of change
  created_at TEXT DEFAULT (datetime('now'))
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_events_outreach ON events(outreach_id);
CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_outreach_angle ON outreach(angle);
CREATE INDEX IF NOT EXISTS idx_outreach_opener ON outreach(opener);
CREATE INDEX IF NOT EXISTS idx_targets_segment ON targets(segment);
CREATE INDEX IF NOT EXISTS idx_signals_type ON signals(type);

-- View: outreach with outcomes (for analysis)
CREATE VIEW IF NOT EXISTS outreach_outcomes AS
SELECT
  o.id AS outreach_id,
  o.angle,
  o.opener,
  o.tone,
  t.name AS target_name,
  t.company,
  t.segment,
  s.type AS signal_type,
  s.urgency AS signal_urgency,
  MAX(CASE WHEN e.event_type = 'connection_sent' THEN e.timestamp END) AS sent_at,
  MAX(CASE WHEN e.event_type = 'connection_accepted' THEN e.timestamp END) AS accepted_at,
  MAX(CASE WHEN e.event_type IN ('replied', 'replied_first') THEN e.timestamp END) AS replied_at,
  MAX(CASE WHEN e.event_type IN ('replied', 'replied_first') THEN e.reply_classification END) AS reply_class,
  MAX(CASE WHEN e.event_type = 'disconnected' THEN e.timestamp END) AS disconnected_at,
  CASE
    WHEN MAX(CASE WHEN e.event_type IN ('replied', 'replied_first') AND e.reply_classification = 'meeting' THEN 1 ELSE 0 END) = 1 THEN 'meeting_booked'
    WHEN MAX(CASE WHEN e.event_type IN ('replied', 'replied_first') THEN 1 ELSE 0 END) = 1 THEN 'replied'
    WHEN MAX(CASE WHEN e.event_type = 'disconnected' THEN 1 ELSE 0 END) = 1 THEN 'disconnected'
    WHEN MAX(CASE WHEN e.event_type = 'connection_accepted' THEN 1 ELSE 0 END) = 1 THEN 'accepted_no_reply'
    WHEN MAX(CASE WHEN e.event_type = 'connection_sent' THEN 1 ELSE 0 END) = 1 THEN 'pending'
    ELSE 'unknown'
  END AS outcome
FROM outreach o
JOIN targets t ON o.target_id = t.id
LEFT JOIN signals s ON o.signal_id = s.id
LEFT JOIN events e ON e.outreach_id = o.id
GROUP BY o.id;
