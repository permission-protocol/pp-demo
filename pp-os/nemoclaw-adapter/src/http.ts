export async function postJson<TResponse>(
  url: string,
  payload: unknown,
  headers: Record<string, string> = {},
): Promise<TResponse> {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      ...headers,
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    throw new Error(`POST ${url} failed with ${response.status} ${response.statusText}`);
  }

  return (await response.json()) as TResponse;
}
