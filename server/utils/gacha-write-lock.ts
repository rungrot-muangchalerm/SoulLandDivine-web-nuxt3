// Serialize the full read/modify/save sequence, so simultaneous GM edits do not overwrite one another.
let pending: Promise<void> = Promise.resolve()

export async function withGachaWriteLock<T>(action: () => Promise<T>): Promise<T> {
  const previous = pending
  let release!: () => void
  pending = new Promise<void>((resolve) => { release = resolve })
  await previous
  try {
    return await action()
  } finally {
    release()
  }
}
