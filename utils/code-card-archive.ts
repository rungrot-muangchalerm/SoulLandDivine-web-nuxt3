export const ARCHIVE_PAGE_SIZE = 12

export function normalizeArchivePage(value: unknown): number {
  if (typeof value !== 'string' || !/^[1-9]\d*$/.test(value)) return 1
  const page = Number(value)
  return Number.isSafeInteger(page) && page <= 100000 ? page : 1
}