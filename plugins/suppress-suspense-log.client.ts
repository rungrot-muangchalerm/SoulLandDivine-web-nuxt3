const suspenseNotice = '<Suspense> is an experimental feature and its API will likely change.'

export default defineNuxtPlugin(() => {
  if (!import.meta.dev) return

  const originalInfo = console.info
  console.info = (...args) => {
    if (args.length === 1 && args[0] === suspenseNotice) return
    originalInfo.apply(console, args)
  }
})
