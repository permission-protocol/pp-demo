/**
 * Agent payment authorization thresholds
 *
 * Controls the dollar limits at which AI agents can initiate payments
 * without explicit human approval. Changes to this file are high-impact
 * and gated by Permission Protocol — a human must sign off before merge.
 *
 * Compliance mapping:
 *  - Reg S-P (Safeguarding customer information / payment integrity)
 *  - SR 11-7 (Model risk management for AI-driven transactions)
 *  - MiCA Article 70 (Crypto-asset transaction safeguards)
 *  - EU AI Act Annex III (High-risk AI systems in financial services)
 */

export interface AgentPaymentPolicy {
  /** Maximum payment in USD an agent can send without human approval. */
  autoApproveUsdMax: number;
  /** Hard ceiling above which the agent is blocked regardless of approval. */
  hardBlockUsdMax: number;
  /** Risk-score threshold (0-100) above which all payments require approval. */
  riskScoreApprovalThreshold: number;
  /** Risk-score threshold above which all payments are blocked. */
  riskScoreBlockThreshold: number;
}

export const AGENT_PAYMENT_POLICY: AgentPaymentPolicy = {
  // Raised from 1,000 → 25,000 to enable larger autonomous treasury operations.
  // This change MUST be reviewed by Compliance + CFO before merge.
  autoApproveUsdMax: 25_000,

  // Hard ceiling above which the agent cannot transact, even with approval.
  hardBlockUsdMax: 250_000,

  // Wallet risk-score threshold (Inca Digital scoring): >70 requires human signoff.
  riskScoreApprovalThreshold: 70,

  // Wallet risk-score threshold: >90 is blocked outright.
  riskScoreBlockThreshold: 90,
};

/**
 * Decides whether an agent payment proceeds, escalates, or is blocked.
 * Every call produces an authority receipt via Permission Protocol.
 */
export function evaluatePayment(
  amountUsd: number,
  walletRiskScore: number,
): "auto_approve" | "require_human_approval" | "block" {
  if (amountUsd > AGENT_PAYMENT_POLICY.hardBlockUsdMax) return "block";
  if (walletRiskScore > AGENT_PAYMENT_POLICY.riskScoreBlockThreshold) return "block";

  if (walletRiskScore > AGENT_PAYMENT_POLICY.riskScoreApprovalThreshold) {
    return "require_human_approval";
  }
  if (amountUsd > AGENT_PAYMENT_POLICY.autoApproveUsdMax) {
    return "require_human_approval";
  }

  return "auto_approve";
}
