type MessageType = 'success' | 'error' | 'warning' | 'info'

function showMessage(type: MessageType, message: unknown) {
  if (!import.meta.client) return

  const alert = document.createElement('div')
  const className = type === 'error' ? 'danger' : type
  alert.className = `alert alert-${className} alert-dismissible fade show position-fixed top-0 end-0 m-3 shadow z-3`
  alert.setAttribute('role', type === 'error' ? 'alert' : 'status')
  alert.textContent = String(message)

  const close = document.createElement('button')
  close.type = 'button'
  close.className = 'btn-close'
  close.setAttribute('aria-label', 'Close')
  close.addEventListener('click', () => alert.remove())
  alert.append(close)
  document.body.append(alert)

  window.setTimeout(() => alert.remove(), 5000)
}

export const BsMessage = {
  success: (message: unknown) => showMessage('success', message),
  error: (message: unknown) => showMessage('error', message),
  warning: (message: unknown) => showMessage('warning', message),
  info: (message: unknown) => showMessage('info', message),
}

export const BsMessageBox = {
  confirm(message: string, title?: string, _options?: Record<string, unknown>) {
    if (!import.meta.client || window.confirm(`${title ? `${title}\n\n` : ''}${message}`)) {
      return Promise.resolve()
    }

    return Promise.reject(new Error('Action cancelled'))
  },
}
