import { randomUUID } from 'node:crypto'
import NodeCache from 'node-cache'
import { sendGamePacket } from './game-server'

export interface CustomEmailTarget {
  serverId: number
  uid: number
}

interface CustomEmailJobInput {
  channel: string
  username: string
  title: string
  senderName: string
  content: string
  targets: CustomEmailTarget[]
  rewardBatches: string[][]
}

interface CustomEmailJobState extends CustomEmailJobInput {
  id: string
  status: 'queued' | 'processing' | 'completed' | 'failed'
  total: number
  processed: number
  sent: number
  failedCount: number
  failures: Array<{ recipient: string; message: string }>
  batchCount: number
  targetCount: number
  error?: string
}

const JOB_TTL_SECONDS = 7 * 24 * 60 * 60
const MAX_FAILURE_DETAILS = 100
const jobs = new NodeCache({ checkperiod: 600, useClones: false })
const pendingJobs: string[] = []
let workerRunning = false

function saveJob(job: CustomEmailJobState) {
  jobs.set(job.id, job, JOB_TTL_SECONDS)
}

function recordFailure(job: CustomEmailJobState, recipient: string, message: string) {
  job.failedCount += 1
  if (job.failures.length < MAX_FAILURE_DETAILS) {
    job.failures.push({ recipient, message })
  }
}

async function processQueue() {
  if (workerRunning) return
  workerRunning = true

  try {
    while (pendingJobs.length) {
      const jobId = pendingJobs.shift()
      if (!jobId) continue
      const job = jobs.get<CustomEmailJobState>(jobId)
      if (!job) continue

      job.status = 'processing'
      saveJob(job)
      try {
        for (const recipient of job.targets) {
          for (let batchIndex = 0; batchIndex < job.rewardBatches.length; batchIndex += 1) {
            try {
              const result = await sendGamePacket({
                serverId: recipient.serverId,
                uid: recipient.uid,
                title: job.title,
                senderName: job.senderName,
                content: job.content,
                reward: job.rewardBatches[batchIndex].join('|'),
              }, 10045, job.channel) as { result?: number; message?: string } | null

              if (result?.result === 1) {
                job.sent += 1
              } else {
                recordFailure(
                  job,
                  `${recipient.serverId}:${recipient.uid} (ชุด ${batchIndex + 1})`,
                  result?.message || 'Game Server ไม่ยืนยันการส่งอีเมล',
                )
              }
            } catch (error) {
              recordFailure(
                job,
                `${recipient.serverId}:${recipient.uid} (ชุด ${batchIndex + 1})`,
                error instanceof Error ? error.message : 'ส่งอีเมลไม่สำเร็จ',
              )
            }

            job.processed += 1
            saveJob(job)
          }
        }
        job.status = 'completed'
        saveJob(job)
      } catch (error) {
        job.status = 'failed'
        job.error = error instanceof Error ? error.message : 'เกิดข้อผิดพลาดระหว่างส่งอีเมล'
        saveJob(job)
        console.error(`Custom email job ${job.id} failed:`, error)
      }
    }
  } finally {
    workerRunning = false
    if (pendingJobs.length) void processQueue()
  }
}

export function enqueueCustomEmail(input: CustomEmailJobInput) {
  const id = randomUUID()
  const total = input.targets.length * input.rewardBatches.length
  const job: CustomEmailJobState = {
    ...input,
    id,
    status: 'queued',
    total,
    processed: 0,
    sent: 0,
    failedCount: 0,
    failures: [],
    batchCount: input.rewardBatches.length,
    targetCount: input.targets.length,
  }

  saveJob(job)
  pendingJobs.push(id)
  void processQueue()
  return id
}

export function getCustomEmailJob(id: string) {
  const job = jobs.get<CustomEmailJobState>(id)
  if (!job) return undefined

  return {
    id: job.id,
    username: job.username,
    channel: job.channel,
    status: job.status,
    total: job.total,
    processed: job.processed,
    sent: job.sent,
    failedCount: job.failedCount,
    failures: job.failures,
    batchCount: job.batchCount,
    targetCount: job.targetCount,
    result: job.status === 'completed' ? (job.failedCount === 0 ? 1 : 0) : undefined,
    error: job.error,
  }
}
