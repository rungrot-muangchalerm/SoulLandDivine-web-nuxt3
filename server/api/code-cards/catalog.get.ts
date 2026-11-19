import catalog from '../../../data/code-card-catalog.json'
import { cardAdmin } from '../../utils/code-cards'
export default defineEventHandler(async event => { await cardAdmin(event); return catalog })
