// Production Nuxt 3 process for Windows hosts with Node.js >= 20.6.
// Credentials remain in the deployment's local .env, outside Git.
module.exports = {
  apps: [{
    name: 'soulland-divine-nuxt3',
    cwd: __dirname,
    script: '.output/server/index.mjs',
    interpreter: 'node',
    node_args: ['--env-file=.env'],
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    watch: false,
    min_uptime: '10s',
    max_restarts: 30,
    exp_backoff_restart_delay: 1000,
    max_memory_restart: '512M',
    env: {
      NODE_ENV: 'production',
      NITRO_HOST: '0.0.0.0',
      NITRO_PORT: '8081',
    },
  }],
};