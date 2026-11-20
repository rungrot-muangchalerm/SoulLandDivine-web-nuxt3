/**
 * Generate the idempotency key for a card batch.
 * crypto.randomUUID() is not exposed in non-secure HTTP browser contexts,
 * whereas crypto.getRandomValues() is available there.
 */
export function createCardRequestId(cryptoSource: Pick<Crypto, 'getRandomValues'> & Partial<Pick<Crypto, 'randomUUID'>> = globalThis.crypto): string {
  if (typeof cryptoSource?.randomUUID === 'function') return cryptoSource.randomUUID()
  if (typeof cryptoSource?.getRandomValues !== 'function') throw new Error('Secure random generation is unavailable')

  const bytes = new Uint8Array(16)
  cryptoSource.getRandomValues(bytes)
  bytes[6] = (bytes[6] & 0x0f) | 0x40 // Version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80 // RFC 4122 variant
  const value = Array.from(bytes, byte => byte.toString(16).padStart(2, '0')).join('')
  return [value.slice(0, 8), value.slice(8, 12), value.slice(12, 16), value.slice(16, 20), value.slice(20)].join('-')
}