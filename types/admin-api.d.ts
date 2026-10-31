import type { NuxtApp } from '#app'

interface ApiClient {
  post<T = unknown>(url: string, body?: unknown): Promise<{ data: T }>
}

declare module '#app' {
  interface NuxtApp {
    $api: ApiClient
  }
}

declare module 'vue' {
  interface ComponentCustomProperties {
    $api: ApiClient
  }
}

export {}
