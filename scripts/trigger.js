const http = require('http');
http.get('http://127.0.0.1:9229/json', (res) => {
  let data = '';
  res.on('data', d => data += d);
  res.on('end', () => {
    const targets = JSON.parse(data);
    const wsUrl = targets[0].webSocketDebuggerUrl;
    const WebSocket = require('ws');
    const ws = new WebSocket(wsUrl);
    ws.on('open', () => {
      ws.send(JSON.stringify({
        id: 1,
        method: 'Runtime.evaluate',
        params: { expression: 'typeof globalThis.saveStateAndExit', returnByValue: true }
      }));
    });
    ws.on('message', (msg) => {
      console.log('Result:', msg.toString());
      setTimeout(() => process.exit(0), 1000);
    });
  });
}).on('error', (e) => console.error(e));
