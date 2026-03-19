export interface DeniedConnection {
  host: string;
  port: number;
  binary: string;
  rawLine: string;
  detectedAt: string;
}

export interface ApprovalBatch {
  requestId: string;
  sandboxName: string;
  createdAt: string;
  entries: DeniedConnection[];
}

export interface PpApprovalReceipt {
  requestId: string;
  approved: boolean;
  receiptId: string;
  approvedAt: string;
  entries: DeniedConnection[];
  sandboxName: string;
  signature?: string;
}
