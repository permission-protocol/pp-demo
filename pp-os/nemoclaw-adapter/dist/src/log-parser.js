const FIELD_PATTERNS = {
    host: /(?:^|\s)dst_host=(?<value>[^\s]+)/,
    port: /(?:^|\s)dst_port=(?<value>\d+)/,
    binary: /(?:^|\s)binary=(?<value>[^\s]+)/
};
export function parseDeniedConnection(line) {
    if (!line.includes("action=deny")) {
        return null;
    }
    const host = FIELD_PATTERNS.host.exec(line)?.groups?.value;
    const port = FIELD_PATTERNS.port.exec(line)?.groups?.value;
    const binary = FIELD_PATTERNS.binary.exec(line)?.groups?.value;
    if (!host || !port || !binary) {
        return null;
    }
    return {
        host,
        port: Number.parseInt(port, 10),
        binary,
        rawLine: line,
        detectedAt: new Date().toISOString()
    };
}


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/src/log-parser.ts