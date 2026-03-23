/**
 * OAuth2 Provider Integration
 * Adds third-party authentication support for production API
 */

export interface OAuthConfig {
  clientId: string;
  clientSecret: string;
  redirectUri: string;
  scopes: string[];
}

export interface AuthToken {
  accessToken: string;
  refreshToken?: string;
  expiresAt: number;
  scopes: string[];
}

export class AuthProvider {
  private config: OAuthConfig;

  constructor(config: OAuthConfig) {
    this.config = config;
  }

  async exchangeCode(code: string): Promise<AuthToken> {
    const response = await fetch('https://oauth.provider.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        grant_type: 'authorization_code',
        code,
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
        redirect_uri: this.config.redirectUri,
      }),
    });

    if (!response.ok) {
      throw new Error(`Token exchange failed: ${response.status}`);
    }

    const data = await response.json() as Record<string, unknown>;
    return {
      accessToken: data.access_token as string,
      refreshToken: data.refresh_token as string | undefined,
      expiresAt: Date.now() + (data.expires_in as number) * 1000,
      scopes: this.config.scopes,
    };
  }

  async refreshToken(token: AuthToken): Promise<AuthToken> {
    if (!token.refreshToken) {
      throw new Error('No refresh token available');
    }

    const response = await fetch('https://oauth.provider.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        grant_type: 'refresh_token',
        refresh_token: token.refreshToken,
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
      }),
    });

    if (!response.ok) {
      throw new Error(`Token refresh failed: ${response.status}`);
    }

    const data = await response.json() as Record<string, unknown>;
    return {
      accessToken: data.access_token as string,
      refreshToken: data.refresh_token as string | undefined ?? token.refreshToken,
      expiresAt: Date.now() + (data.expires_in as number) * 1000,
      scopes: token.scopes,
    };
  }
}
