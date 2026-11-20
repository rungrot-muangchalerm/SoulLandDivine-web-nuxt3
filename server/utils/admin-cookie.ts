import { getRequestProtocol, type H3Event } from 'h3'

// Cookies must only require HTTPS when the incoming request uses HTTPS.
export function useSecureAdminCookie(event: H3Event): boolean {
  return getRequestProtocol(event) === 'https'
}
