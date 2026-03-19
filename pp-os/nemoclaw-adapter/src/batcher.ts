import type { DeniedConnection } from "./types.js";

export type BatchHandler = (entries: DeniedConnection[]) => Promise<void>;

function dedupeKey(entry: DeniedConnection): string {
  return `${entry.host}:${entry.port}:${entry.binary}`;
}

export class DebouncedBatcher {
  #pending = new Map<string, DeniedConnection>();
  #timer: NodeJS.Timeout | undefined;
  #windowMs: number;
  #handler: BatchHandler;

  constructor(windowMs: number, handler: BatchHandler) {
    this.#windowMs = windowMs;
    this.#handler = handler;
  }

  add(entry: DeniedConnection): void {
    this.#pending.set(dedupeKey(entry), entry);
    this.#armTimer();
  }

  async flush(): Promise<void> {
    if (this.#timer) {
      clearTimeout(this.#timer);
      this.#timer = undefined;
    }

    if (this.#pending.size === 0) {
      return;
    }

    const entries = [...this.#pending.values()];
    this.#pending.clear();
    await this.#handler(entries);
  }

  #armTimer(): void {
    if (this.#timer) {
      clearTimeout(this.#timer);
    }

    this.#timer = setTimeout(() => {
      void this.flush();
    }, this.#windowMs);
  }
}
