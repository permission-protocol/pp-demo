export async function postJson(url, payload, headers = {}) {
    const response = await fetch(url, {
        method: "POST",
        headers: {
            "content-type": "application/json",
            ...headers
        },
        body: JSON.stringify(payload)
    });
    if (!response.ok) {
        throw new Error(`POST ${url} failed with ${response.status} ${response.statusText}`);
    }
    return await response.json();
}


//# sourceURL=/Users/moltbot/.openclaw/workspace/pp-os/nemoclaw-adapter/src/http.ts