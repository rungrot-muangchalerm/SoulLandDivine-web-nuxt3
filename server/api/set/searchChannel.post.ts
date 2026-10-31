import { getDatabase } from '../../utils/database'

export default defineEventHandler(async (event) => {
  const [rows] = await getDatabase().query(
    'SELECT `id`, `name`, `index` FROM `channel_list` ORDER BY `id`',
  )
  return rows
})
