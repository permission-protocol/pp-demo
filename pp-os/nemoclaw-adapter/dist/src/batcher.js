function dedupeKey(entry) {
    return `${entry.host}:${entry.port}:${entry.binary}`;
}
export class DebouncedBatcher {
    #pending = new Map();
    #timer;
    #windowMs;
    #handler;
    constructor(windowMs, handler){
        this.#windowMs = windowMs;
        this.#handler = handler;
    }
    add(entry) {
        this.#pending.set(dedupeKey(entry), entry);
        this.#armTimer();
    }
    async flush() {
        if (this.#timer) {
            clearTimeout(this.#timer);
            this.#timer = undefined;
        }
        if (this.#pending.size === 0) {
            return;
        }
        const entries = [
            ...this.#pending.values()
        ];
        this.#pending.clear();
        await this.#handler(entries);
    }
    #armTimer() {
        if (this.#timer) {
            clearTimeout(this.#timer);
        }
        this.#timer = setTimeout(()=>{
            void this.flush();
        }, this.#windowMs);
    }
}


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/src/batcher.ts