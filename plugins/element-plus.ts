import {
  ElAlert,
  ElButton,
  ElCard,
  ElForm,
  ElFormItem,
  ElInput,
  ElOption,
  ElSelect,
  ID_INJECTION_KEY,
  ZINDEX_INJECTION_KEY,
} from 'element-plus'

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.provide(ID_INJECTION_KEY, { prefix: 100, current: 0 })
  nuxtApp.vueApp.provide(ZINDEX_INJECTION_KEY, { current: 0 })
  const components = [
    ['ElAlert', ElAlert],
    ['ElButton', ElButton],
    ['ElCard', ElCard],
    ['ElForm', ElForm],
    ['ElFormItem', ElFormItem],
    ['ElInput', ElInput],
    ['ElOption', ElOption],
    ['ElSelect', ElSelect],
  ] as const
  for (const component of components) {
    nuxtApp.vueApp.component(component[0], component[1])
  }
})
