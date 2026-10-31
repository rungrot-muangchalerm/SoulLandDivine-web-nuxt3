import {
  Comment,
  Fragment,
  computed,
  defineComponent,
  h,
  inject,
  provide,
  ref,
  Teleport,
  type VNode,
} from 'vue'

type FormContext = { rules?: Record<string, Array<{ required?: boolean }>> }
type TableScope = {
  row: Record<string, unknown>
  $index: number
  column: Record<string, unknown>
}
type CheckboxGroupContext = {
  model: () => unknown[]
  update: (value: unknown[]) => void
}

const formContextKey = Symbol('bootstrap-form')
const checkboxGroupKey = Symbol('bootstrap-checkbox-group')

function classes(value: unknown) {
  return Array.isArray(value) ? value : value ? [value] : []
}

function optionNodes(nodes: VNode[] = []): VNode[] {
  return nodes.flatMap((node) => {
    if (node.type === Comment) return []
    if (node.type === Fragment && Array.isArray(node.children)) {
      return optionNodes(node.children as VNode[])
    }
    return [node]
  })
}

const BsButton = defineComponent({
  name: 'BsButton',
  inheritAttrs: false,
  props: {
    type: { type: String, default: 'default' },
    size: String,
    plain: Boolean,
    loading: Boolean,
    disabled: Boolean,
    nativeType: String,
  },
  setup(props, { attrs, slots }) {
    return () => {
      const variant = props.type === 'text' ? 'link' : props.type === 'default' ? 'secondary' : props.type
      const buttonClass = props.plain ? `btn-outline-${variant}` : `btn-${variant}`
      return h('button', {
        ...attrs,
        type: props.nativeType || 'button',
        disabled: props.disabled || props.loading || attrs.disabled !== undefined,
        class: ['btn', buttonClass, props.size === 'small' ? 'btn-sm' : '', ...classes(attrs.class)],
      }, [
        ...(props.loading ? [h('span', { class: 'spinner-border spinner-border-sm me-2', role: 'status' })] : []),
        ...(slots.default?.() ?? []),
      ])
    }
  },
})

const BsInput = defineComponent({
  name: 'BsInput',
  inheritAttrs: false,
  props: {
    modelValue: { type: [String, Number], default: '' },
    type: { type: String, default: 'text' },
    placeholder: String,
    rows: Number,
    disabled: Boolean,
    readonly: Boolean,
    required: Boolean,
  },
  emits: ['update:modelValue', 'input', 'change', 'blur', 'focus'],
  setup(props, { attrs, emit }) {
    const formItem = inject<{ required: boolean }>(formContextKey, { required: false })
    return () => {
      const textarea = props.type === 'textarea'
      const tag = textarea ? 'textarea' : 'input'
      const value = props.modelValue == null ? '' : String(props.modelValue)
      const inputAttrs = {
        ...attrs,
        class: ['form-control', ...classes(attrs.class)],
        type: textarea ? undefined : props.type,
        rows: textarea ? props.rows : undefined,
        value,
        placeholder: props.placeholder,
        disabled: props.disabled,
        readonly: props.readonly,
        required: props.required || formItem.required || undefined,
        onInput: (event: Event) => {
          const target = event.target as HTMLInputElement | HTMLTextAreaElement
          emit('update:modelValue', target.value)
          emit('input', target.value)
        },
        onChange: (event: Event) => emit('change', (event.target as HTMLInputElement).value),
        onBlur: (event: FocusEvent) => emit('blur', event),
        onFocus: (event: FocusEvent) => emit('focus', event),
      }
      return h(tag, inputAttrs)
    }
  },
})

const BsOption = defineComponent({
  name: 'BsOption',
  props: {
    value: { type: [String, Number, Boolean, Object], default: '' },
    label: { type: [String, Number], default: '' },
    disabled: Boolean,
  },
  setup(props, { slots }) {
    return () => h('option', {
      value: String(props.value),
      disabled: props.disabled,
    }, slots.default?.() ?? String(props.label ?? ''))
  },
})

const BsSelect = defineComponent({
  name: 'BsSelect',
  inheritAttrs: false,
  props: {
    modelValue: { type: [String, Number, Boolean, Object, Array], default: '' },
    placeholder: String,
    disabled: Boolean,
    clearable: Boolean,
  },
  emits: ['update:modelValue', 'change'],
  setup(props, { attrs, emit, slots }) {
    const formItem = inject<{ required: boolean }>(formContextKey, { required: false })
    return () => {
      const children = slots.default?.() ?? []
      const selectedValue = Array.isArray(props.modelValue) ? props.modelValue[0] : props.modelValue
      return h('select', {
        ...attrs,
        class: ['form-select', ...classes(attrs.class)],
        value: selectedValue == null ? '' : String(selectedValue),
        disabled: props.disabled,
        required: formItem.required || undefined,
        onChange: (event: Event) => {
          const select = event.target as HTMLSelectElement
          const matchingOption = optionNodes(children).find((node) => String(node.props?.value ?? '') === select.value)
          const value = matchingOption?.props?.value ?? select.value
          emit('update:modelValue', value)
          emit('change', value)
        },
      }, children)
    }
  },
})

const BsForm = defineComponent({
  name: 'BsForm',
  inheritAttrs: false,
  props: {
    model: Object,
    rules: Object,
    inline: Boolean,
    labelPosition: String,
    labelWidth: String,
  },
  setup(props, { attrs, slots, expose }) {
    const formElement = ref<HTMLFormElement>()
    provide(formContextKey, { rules: props.rules as FormContext['rules'] })
    const validate = (callback?: (valid: boolean) => void) => {
      const valid = formElement.value?.reportValidity() ?? true
      callback?.(valid)
      return Promise.resolve(valid)
    }
    expose({
      validate,
      clearValidate: () => formElement.value?.querySelectorAll('.is-invalid').forEach((item) => item.classList.remove('is-invalid')),
      resetFields: () => formElement.value?.reset(),
    })
    return () => h('form', {
      ...attrs,
      ref: formElement,
      class: [props.inline ? 'row g-3 align-items-end' : '', ...classes(attrs.class)],
      onSubmit: (event: Event) => event.preventDefault(),
    }, slots.default?.())
  },
})

const BsFormItem = defineComponent({
  name: 'BsFormItem',
  inheritAttrs: false,
  props: {
    label: String,
    prop: String,
    required: Boolean,
    labelWidth: String,
    error: String,
  },
  setup(props, { attrs, slots }) {
    const form = inject<FormContext>(formContextKey, {})
    const required = computed(() => props.required || Boolean(form.rules?.[props.prop ?? '']?.some((rule) => rule.required)))
    provide(formContextKey, { required: required.value })
    return () => h('div', {
      ...attrs,
      class: ['mb-3', ...classes(attrs.class)],
    }, [
      ...(props.label ? [h('label', { class: 'form-label' }, [
        props.label,
        ...(required.value ? [h('span', { class: 'text-danger ms-1', 'aria-hidden': 'true' }, '*')] : []),
      ])] : []),
      ...(slots.default?.() ?? []),
      ...(props.error ? [h('div', { class: 'invalid-feedback d-block' }, props.error)] : []),
    ])
  },
})

const BsBreadcrumb = defineComponent({
  name: 'BsBreadcrumb',
  props: { separator: String },
  setup(_props, { slots }) {
    return () => h('nav', { 'aria-label': 'breadcrumb' }, [
      h('ol', { class: 'breadcrumb mb-3' }, slots.default?.()),
    ])
  },
})

const BsBreadcrumbItem = defineComponent({
  name: 'BsBreadcrumbItem',
  props: { to: [String, Object] },
  setup(props, { slots }) {
    return () => h('li', { class: 'breadcrumb-item' }, props.to
      ? h('a', { href: typeof props.to === 'string' ? props.to : undefined }, slots.default?.())
      : slots.default?.())
  },
})

function valueAtPath(row: Record<string, unknown>, path?: string) {
  if (!path) return ''
  return path.split('.').reduce<unknown>((current, key) => {
    return current && typeof current === 'object' ? (current as Record<string, unknown>)[key] : undefined
  }, row)
}

const BsTableColumn = defineComponent({
  name: 'BsTableColumn',
  props: {
    prop: String,
    label: String,
    width: [String, Number],
    minWidth: [String, Number],
    align: String,
    type: String,
  },
  setup() {
    return () => null
  },
})

const BsTable = defineComponent({
  name: 'BsTable',
  inheritAttrs: false,
  props: {
    data: { type: Array, default: () => [] },
    stripe: Boolean,
    border: Boolean,
    size: String,
    rowKey: [String, Function],
    emptyText: { type: String, default: 'ไม่มีข้อมูล' },
  },
  setup(props, { attrs, slots }) {
    const expandedRows = ref(new Set<number>())
    return () => {
      const columns = optionNodes(slots.default?.() ?? [])
      const tableClasses = [
        'table',
        'table-hover',
        props.stripe ? 'table-striped' : '',
        props.border ? 'table-bordered' : '',
        props.size === 'small' ? 'table-sm' : '',
        ...classes(attrs.class),
      ]
      const rows = props.data as Array<Record<string, unknown>>
      const header = h('thead', { class: 'table-light' }, [
        h('tr', columns.map((column, index) => h('th', {
          key: index,
          scope: 'col',
          class: column.props?.align ? `text-${column.props.align}` : '',
          width: column.props?.width ? String(column.props.width) : undefined,
        }, String(column.props?.label ?? '')))),
      ])
      const bodyRows: VNode[] = []
      rows.forEach((row, rowIndex) => {
        const key = typeof props.rowKey === 'function'
          ? String(props.rowKey(row))
          : String((row as Record<string, unknown>)[String(props.rowKey ?? 'id')] ?? rowIndex)
        bodyRows.push(h('tr', { key }, columns.map((column, columnIndex) => {
          const columnProps = column.props ?? {}
          const value = valueAtPath(row, String(columnProps.prop ?? ''))
          const scope: TableScope = { row, $index: rowIndex, column: columnProps }
          const content = column.children && typeof column.children === 'object' && 'default' in column.children
            ? (column.children.default as (scope: TableScope) => VNode[])(scope)
            : String(value ?? '')
          return h('td', {
            key: columnIndex,
            class: columnProps.align ? `text-${columnProps.align}` : '',
          }, columnProps.type === 'index' ? String(rowIndex + 1) : content)
        })))
      })
      if (!bodyRows.length) {
        bodyRows.push(h('tr', { key: 'empty' }, [
          h('td', { colspan: Math.max(columns.length, 1), class: 'text-center text-body-secondary py-4' }, props.emptyText),
        ]))
      }
      return h('div', { class: ['table-responsive', ...classes(attrs.class)] }, [
        h('table', { class: tableClasses }, [header, h('tbody', bodyRows)]),
      ])
    }
  },
})

const BsDialog = defineComponent({
  name: 'BsDialog',
  inheritAttrs: false,
  props: {
    modelValue: Boolean,
    visible: Boolean,
    title: String,
    width: String,
    center: Boolean,
    closeOnClickModal: { type: Boolean, default: true },
  },
  emits: ['update:modelValue', 'update:visible', 'close', 'open'],
  setup(props, { attrs, emit, slots }) {
    const isOpen = computed(() => props.modelValue || props.visible)
    const close = () => {
      emit('update:modelValue', false)
      emit('update:visible', false)
      emit('close')
    }
    return () => isOpen.value ? h(Teleport, { to: 'body' }, [
      h('div', {
        class: 'modal-backdrop fade show',
        onClick: props.closeOnClickModal ? close : undefined,
      }),
      h('div', { class: 'modal d-block', tabindex: -1, role: 'dialog', 'aria-modal': 'true' }, [
        h('div', { class: ['modal-dialog', props.center ? 'modal-dialog-centered' : ''] }, [
          h('div', { ...attrs, class: ['modal-content', ...classes(attrs.class)] }, [
            h('div', { class: 'modal-header' }, [
              ...(slots.header?.() ?? [h('h2', { class: 'modal-title fs-5' }, props.title ?? '')]),
              h('button', { type: 'button', class: 'btn-close', 'aria-label': 'Close', onClick: close }),
            ]),
            h('div', { class: 'modal-body' }, slots.default?.()),
            ...(slots.footer ? [h('div', { class: 'modal-footer' }, slots.footer())] : []),
          ]),
        ]),
      ]),
    ]) : null
  },
})

const BsPagination = defineComponent({
  name: 'BsPagination',
  props: {
    currentPage: { type: Number, default: 1 },
    pageSize: { type: Number, default: 10 },
    total: { type: Number, default: 0 },
    layout: String,
  },
  emits: ['current-change', 'update:currentPage'],
  setup(props, { emit }) {
    return () => {
      const pageCount = Math.max(1, Math.ceil(props.total / Math.max(props.pageSize, 1)))
      const move = (page: number) => {
        if (page < 1 || page > pageCount || page === props.currentPage) return
        emit('update:currentPage', page)
        emit('current-change', page)
      }
      const pages = Array.from({ length: Math.min(pageCount, 5) }, (_, index) => {
        const firstPage = Math.max(1, Math.min(props.currentPage - 2, pageCount - 4))
        return firstPage + index
      }).filter((page) => page <= pageCount)
      return h('div', { class: 'd-flex flex-wrap justify-content-between align-items-center gap-2 my-3' }, [
        h('span', { class: 'small text-body-secondary' }, `ทั้งหมด ${props.total} รายการ`),
        h('nav', { 'aria-label': 'pagination' }, [
          h('ul', { class: 'pagination pagination-sm mb-0' }, [
            h('li', { class: ['page-item', props.currentPage <= 1 ? 'disabled' : ''] }, [
              h('button', { class: 'page-link', type: 'button', disabled: props.currentPage <= 1, onClick: () => move(props.currentPage - 1) }, 'ก่อนหน้า'),
            ]),
            ...pages.map((page) => h('li', { class: ['page-item', page === props.currentPage ? 'active' : ''], key: page }, [
              h('button', { class: 'page-link', type: 'button', onClick: () => move(page) }, String(page)),
            ])),
            h('li', { class: ['page-item', props.currentPage >= pageCount ? 'disabled' : ''] }, [
              h('button', { class: 'page-link', type: 'button', disabled: props.currentPage >= pageCount, onClick: () => move(props.currentPage + 1) }, 'ถัดไป'),
            ]),
          ]),
        ]),
      ])
    }
  },
})

const BsDatePicker = defineComponent({
  name: 'BsDatePicker',
  inheritAttrs: false,
  props: {
    modelValue: { type: [String, Array, Date], default: '' },
    type: { type: String, default: 'date' },
    placeholder: String,
    valueFormat: String,
    rangeSeparator: { type: String, default: ' - ' },
    disabled: Boolean,
  },
  emits: ['update:modelValue', 'change'],
  setup(props, { attrs, emit }) {
    const isRange = computed(() => props.type.includes('range'))
    const inputType = computed(() => props.type.includes('time') ? 'datetime-local' : 'date')
    const toInputValue = (value: unknown) => {
      if (!value) return ''
      const text = value instanceof Date ? value.toISOString() : String(value)
      return inputType.value === 'datetime-local' ? text.replace(' ', 'T').slice(0, 16) : text.slice(0, 10)
    }
    const fromInputValue = (value: string) => {
      return inputType.value === 'datetime-local' && props.valueFormat?.includes('HH')
        ? value.replace('T', ' ') + ':00'
        : value
      }
    const values = () => Array.isArray(props.modelValue)
      ? props.modelValue
      : typeof props.modelValue === 'string' && props.modelValue.includes(props.rangeSeparator)
        ? props.modelValue.split(props.rangeSeparator)
        : ['', '']
    const updateRange = (index: number, value: string) => {
      const next = values().slice(0, 2)
      while (next.length < 2) next.push('')
      next[index] = fromInputValue(value)
      const output = Array.isArray(props.modelValue) ? next : next.join(props.rangeSeparator)
      emit('update:modelValue', output)
      emit('change', output)
    }
    return () => {
      const common = {
        class: ['form-control', ...classes(attrs.class)],
        type: inputType.value,
        disabled: props.disabled,
      }
      return isRange.value
        ? h('div', { class: 'd-flex align-items-center gap-2' }, [
          h('input', { ...common, value: toInputValue(values()[0]), onInput: (event: Event) => updateRange(0, (event.target as HTMLInputElement).value) }),
          h('span', { class: 'text-body-secondary' }, 'ถึง'),
          h('input', { ...common, value: toInputValue(values()[1]), onInput: (event: Event) => updateRange(1, (event.target as HTMLInputElement).value) }),
        ])
        : h('input', {
          ...common,
          value: toInputValue(props.modelValue),
          placeholder: props.placeholder,
          onInput: (event: Event) => {
            const value = fromInputValue((event.target as HTMLInputElement).value)
            emit('update:modelValue', value)
            emit('change', value)
          },
        })
    }
  },
})

const BsSwitch = defineComponent({
  name: 'BsSwitch',
  props: {
    modelValue: { type: [Boolean, String, Number], default: false },
    activeValue: { type: [Boolean, String, Number], default: true },
    inactiveValue: { type: [Boolean, String, Number], default: false },
    activeText: String,
    inactiveText: String,
    disabled: Boolean,
  },
  emits: ['update:modelValue', 'change'],
  setup(props, { attrs, emit }) {
    return () => h('div', { class: 'form-check form-switch d-inline-flex align-items-center gap-2' }, [
      h('input', {
        ...attrs,
        class: ['form-check-input', ...classes(attrs.class)],
        type: 'checkbox',
        role: 'switch',
        checked: props.modelValue === props.activeValue,
        disabled: props.disabled,
        onChange: (event: Event) => {
          const value = (event.target as HTMLInputElement).checked ? props.activeValue : props.inactiveValue
          emit('update:modelValue', value)
          emit('change', value)
        },
      }),
      h('label', { class: 'form-check-label' }, props.modelValue === props.activeValue ? props.activeText : props.inactiveText),
    ])
  },
})

const BsCheckboxGroup = defineComponent({
  name: 'BsCheckboxGroup',
  props: { modelValue: { type: Array, default: () => [] } },
  emits: ['update:modelValue', 'change'],
  setup(props, { attrs, emit, slots }) {
    provide(checkboxGroupKey, {
      model: () => props.modelValue,
      update: (value: unknown[]) => {
        emit('update:modelValue', value)
        emit('change', value)
      },
    })
    return () => h('div', { ...attrs, class: ['d-flex flex-wrap gap-3', ...classes(attrs.class)] }, slots.default?.())
  },
})

const BsCheckbox = defineComponent({
  name: 'BsCheckbox',
  props: {
    modelValue: { type: [Boolean, Array], default: false },
    label: { type: [String, Number], default: '' },
    value: { type: [String, Number, Boolean, Object], default: '' },
    disabled: Boolean,
  },
  emits: ['update:modelValue', 'change'],
  setup(props, { attrs, emit, slots }) {
    const group = inject<CheckboxGroupContext | undefined>(checkboxGroupKey, undefined)
    return () => {
      const checkedValues = group?.model() ?? (Array.isArray(props.modelValue) ? props.modelValue : [])
      const checked = group
        ? checkedValues.includes(props.value)
        : Array.isArray(props.modelValue) ? checkedValues.includes(props.value) : Boolean(props.modelValue)
      const change = (event: Event) => {
        const isChecked = (event.target as HTMLInputElement).checked
        if (group || Array.isArray(props.modelValue)) {
          const next = isChecked
            ? [...checkedValues, props.value]
            : checkedValues.filter((value) => value !== props.value)
          if (group) group.update(next)
          else emit('update:modelValue', next)
          emit('change', next)
        } else {
          emit('update:modelValue', isChecked)
          emit('change', isChecked)
        }
      }
      return h('div', { class: 'form-check' }, [
        h('input', {
          ...attrs,
          class: ['form-check-input', ...classes(attrs.class)],
          type: 'checkbox',
          checked,
          disabled: props.disabled,
          value: props.value,
          onChange: change,
        }),
        h('label', { class: 'form-check-label' }, slots.default?.() ?? String(props.label)),
      ])
    }
  },
})

const BsUpload = defineComponent({
  name: 'BsUpload',
  props: {
    action: String,
    data: { type: Object, default: () => ({}) },
    autoUpload: { type: Boolean, default: true },
    multiple: Boolean,
    accept: String,
  },
  emits: ['change', 'progress', 'remove', 'success', 'error'],
  setup(props, { attrs, emit, slots, expose }) {
    const input = ref<HTMLInputElement>()
    const files = ref<File[]>([])
    const clearFiles = () => {
      files.value = []
      if (input.value) input.value.value = ''
    }
    const submit = async () => {
      if (!props.action || !files.value.length) return
      const body = new FormData()
      Object.entries(props.data as Record<string, unknown>).forEach(([key, value]) => body.append(key, String(value)))
      files.value.forEach((file) => body.append('file', file))
      try {
        const response = await fetch(props.action, { method: 'POST', body })
        const result = await response.json()
        if (!response.ok) throw new Error(result?.message || response.statusText)
        emit('success', result, files.value[0], files.value)
      } catch (error) {
        emit('error', error)
      }
    }
    expose({ submit, clearFiles })
    return () => h('div', { ...attrs }, [
      h('input', {
        ref: input,
        class: 'form-control mb-2',
        type: 'file',
        multiple: props.multiple,
        accept: props.accept,
        onChange: (event: Event) => {
          const selected = Array.from((event.target as HTMLInputElement).files ?? [])
          files.value = selected
          emit('change', selected[0], selected)
          if (props.autoUpload) void submit()
        },
      }),
      ...(files.value.length ? [h('ul', { class: 'list-group mb-2' }, files.value.map((file) => h('li', { class: 'list-group-item d-flex justify-content-between', key: file.name }, [
        file.name,
        h('button', { class: 'btn btn-sm btn-outline-danger', type: 'button', onClick: () => { files.value = files.value.filter((item) => item !== file); emit('remove', file, files.value) } }, 'ลบ'),
      ])))] : []),
      ...(slots.default?.() ?? []),
    ])
  },
})

export default defineNuxtPlugin((nuxtApp) => {
  const components = [
    BsButton,
    BsInput,
    BsOption,
    BsSelect,
    BsForm,
    BsFormItem,
    BsBreadcrumb,
    BsBreadcrumbItem,
    BsTable,
    BsTableColumn,
    BsDialog,
    BsPagination,
    BsDatePicker,
    BsSwitch,
    BsCheckbox,
    BsCheckboxGroup,
    BsUpload,
  ]
  for (const component of components) {
    nuxtApp.vueApp.component(component.name!, component)
  }
})
