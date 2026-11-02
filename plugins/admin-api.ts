export default defineNuxtPlugin(() => {
  return {
    provide: {
      api: {
        async post<T = unknown>(url: string, body?: unknown) {
          const data = await $fetch<T>(url, {
            method: 'POST',
            body: body ?? {},
          })
          return { data }
        },
        async get<T = unknown>(url: string) {
          const data = await $fetch<T>(url)
          return { data }
        },
      },
    },
  }
})
