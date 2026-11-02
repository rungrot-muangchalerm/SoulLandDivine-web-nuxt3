import { getGameDatabase } from '../../utils/database'

export default defineEventHandler(async (event) => {
  const [rows] = await getGameDatabase().query(
    'SELECT `id`, `name`, `index` FROM `channel_list` ORDER BY `id`',
  )
  return rows
})
