import type { PluginAPI } from '@ampcode/plugin'

export default function (amp: PluginAPI) {
  amp.registerCommand(
    'impeccable',
    {
      title: '/impeccable',
      category: 'design',
      description: 'Use Impeccable for frontend design work.',
    },
    async (ctx) => {
      const args = (await ctx.ui.input({
        title: '/impeccable',
        helpText: 'Optional arguments',
        submitButtonText: 'Run',
      }))?.trim()

      const message = args
        ? 'Use the impeccable skill. Treat this as the /impeccable arguments: ' + args
        : 'Use the impeccable skill.'
      await ctx.thread?.append([{ type: 'user-message', content: message }])
    },
  )
}
