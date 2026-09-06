-- blink.cmp (completion)
require('luasnip.loaders.from_vscode').lazy_load()

local luasnip = require('luasnip')
local snippet = luasnip.snippet
local insert = luasnip.insert_node
local fmt = require('luasnip.extras.fmt').fmt

luasnip.add_snippets('odin', {
  snippet('lit', fmt([[
{} {{
  {} = {},
}}
]], {
    insert(1, 'Type'),
    insert(2, 'field'),
    insert(3, 'value'),
  })),
  snippet('plit', fmt([[
&{} {{
  {} = {},
}}
]], {
    insert(1, 'Type'),
    insert(2, 'field'),
    insert(3, 'value'),
  })),
  snippet('sdlpipe', fmt([[
{} := sdl.CreateGPUGraphicsPipeline(
  {},
  &sdl.GPUGraphicsPipelineCreateInfo {{
    vertex_shader = {},
    fragment_shader = {},
    primitive_type = .TRIANGLELIST,
    target_info = {{
      num_color_targets = 1,
      color_target_descriptions = &sdl.GPUColorTargetDescription {{
        format = sdl.GetGPUSwapchainTextureFormat({}, {}),
      }},
    }},
  }},
)
]], {
    insert(1, 'pipeline'),
    insert(2, 'gpu'),
    insert(3, 'vertex_shader'),
    insert(4, 'fragment_shader'),
    insert(5, 'gpu'),
    insert(6, 'window'),
  })),
})

require('nvim-autopairs').setup({
  check_ts = true,
  disable_filetype = { 'TelescopePrompt' },
})

require('blink.cmp').setup({
  keymap = {
    preset = 'super-tab',
    ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    ['<CR>'] = { 'select_and_accept', 'fallback' },
    ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },
  snippets = { preset = 'luasnip' },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  signature = {
    enabled = true,
    trigger = {
      enabled = true,
      show_on_accept = true,
      show_on_insert = true,
      show_on_keyword = true,
      show_on_trigger_character = true,
    },
    window = {
      border = 'rounded',
      show_documentation = true,
    },
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
})

