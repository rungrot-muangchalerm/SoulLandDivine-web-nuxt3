export function getCookie(name: string): string {
  if (import.meta.server) return ''

  const key = `${encodeURIComponent(name)}=`
  const entry = document.cookie
    .split('; ')
    .find((cookie) => cookie.startsWith(key))
  return entry ? decodeURIComponent(entry.slice(key.length)) : ''
}

export function setCookie(name: string, value: string, hours = 2): void {
  if (import.meta.server) return

  const expires = new Date(Date.now() + hours * 60 * 60 * 1000).toUTCString()
  document.cookie = `${encodeURIComponent(name)}=${encodeURIComponent(value)}; expires=${expires}; path=/; SameSite=Lax`
}
