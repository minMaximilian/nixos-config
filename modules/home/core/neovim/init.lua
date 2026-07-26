require('nixCatsUtils').setup {
  non_nix_value = true,
}

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Clipboard yank/paste
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to clipboard' })
vim.keymap.set('n', '<leader>Y', '"+Y', { desc = 'Yank line to clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p', { desc = 'Paste from clipboard' })

-- Colorscheme from stylix
local colors = nixCats.extra.colors
if colors then
  require('base16-colorscheme').setup({
    base00 = '#' .. colors.base00,
    base01 = '#' .. colors.base01,
    base02 = '#' .. colors.base02,
    base03 = '#' .. colors.base03,
    base04 = '#' .. colors.base04,
    base05 = '#' .. colors.base05,
    base06 = '#' .. colors.base06,
    base07 = '#' .. colors.base07,
    base08 = '#' .. colors.base08,
    base09 = '#' .. colors.base09,
    base0A = '#' .. colors.base0A,
    base0B = '#' .. colors.base0B,
    base0C = '#' .. colors.base0C,
    base0D = '#' .. colors.base0D,
    base0E = '#' .. colors.base0E,
    base0F = '#' .. colors.base0F,
  })
end

vim.opt.number = true
vim.opt.relativenumber = true

vim.o.autoindent = true
vim.o.copyindent = true
vim.o.breakindent = true
vim.o.termguicolors = true
vim.o.showcmd = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.list = true
vim.opt.listchars = {
  tab = "▏ ",
  trail = "·",
  extends = "»",
  precedes = "«",
}

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN] = '▲',
      [vim.diagnostic.severity.INFO] = '●',
      [vim.diagnostic.severity.HINT] = '○',
    },
  },
  underline = true,
  virtual_text = {
    spacing = 2,
    source = 'if_many',
    prefix = '●',
  },
  float = {
    border = 'rounded',
    source = true,
  },
})

-- Auto-save when leaving insert mode or switching away
vim.o.autowriteall = true
vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged', 'FocusLost', 'BufLeave' }, {
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].modified and vim.bo[buf].buftype == '' and vim.fn.bufname(buf) ~= '' then
      vim.api.nvim_buf_call(buf, function() vim.cmd('silent! write') end)
    end
  end,
})

-- Format on :w (only when an LSP client is attached)
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    if #vim.lsp.get_clients({ bufnr = args.buf }) > 0 then
      vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
    end
  end,
})

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>h', builtin.help_tags, { desc = 'Help tags' })

-- Treesitter
vim.filetype.add({
  extension = {
    comp = 'glsl',
    frag = 'glsl',
    geom = 'glsl',
    glsl = 'glsl',
    odin = 'odin',
    tesc = 'glsl',
    tese = 'glsl',
    vert = 'glsl',
  },
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'bash',
    'c_sharp',
    'cs',
    'gdresource',
    'gdscript',
    'gdshader',
    'glsl',
    'json',
    'lua',
    'markdown',
    'nix',
    'odin',
    'toml',
    'yaml',
    'zig',
    'zsh',
  },
  callback = function()
    vim.treesitter.start()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

vim.treesitter.language.register('c_sharp', 'cs')
vim.treesitter.language.register('godot_resource', 'gdresource')
vim.treesitter.language.register('bash', 'zsh')
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldenable = false

-- LSP
--
-- How language servers get attached:
--   1. nvim-lspconfig provides config files in its lsp/ directory, each
--      defining `cmd`, `filetypes`, and `root_markers` for a server.
--   2. `vim.lsp.enable('server_name')` tells Neovim to auto-activate that
--      server whenever a buffer matches the config's `filetypes`.
--   3. When you open a file (e.g. a .lua file), Neovim checks enabled configs,
--      finds a matching filetype, looks for root_markers (like .git, .luarc.json),
--      and starts the server — attaching it to that buffer.
--   4. You can override any config with `vim.lsp.config('name', { ... })` before
--      calling `vim.lsp.enable`.
--
-- In short: filetypes trigger attachment, root_markers determine the project root,
-- and nvim-lspconfig supplies sensible defaults for both.

local cmp_capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.config('lua_ls', { capabilities = cmp_capabilities })
vim.lsp.enable('lua_ls')

vim.lsp.config('nixd', { capabilities = cmp_capabilities })
vim.lsp.enable('nixd')

vim.lsp.config('zls', { capabilities = cmp_capabilities })
vim.lsp.enable('zls')

vim.lsp.config('ols', { capabilities = cmp_capabilities })
vim.lsp.enable('ols')

vim.lsp.config('glsl_analyzer', { capabilities = cmp_capabilities })
vim.lsp.enable('glsl_analyzer')

-- Godot / GDScript
--
-- Godot's editor itself ships the GDScript language server. When the editor
-- is open with a project loaded, it listens on TCP 127.0.0.1:6005 (LSP) and
-- 127.0.0.1:6006 (DAP). nvim-lspconfig ships a `gdscript` config that
-- connects to that port; we just enable it. The server attaches when a `.gd`
-- buffer is opened inside a project containing `project.godot`.
if nixCats('godot') then
  vim.filetype.add({
    extension = {
      gd = 'gdscript',
      tscn = 'gdresource',
      tres = 'gdresource',
      gdshader = 'gdshader',
    },
  })

  vim.lsp.config('gdscript', {
    capabilities = cmp_capabilities,
    on_attach = function(client)
      -- Godot's LSP doesn't implement textDocument/didClose; suppress to
      -- avoid spurious errors when buffers are closed.
      local _notify = client.notify
      client.notify = function(method, params)
        if method == 'textDocument/didClose' then return true end
        return _notify(method, params)
      end
    end,
  })
  vim.lsp.enable('gdscript')

  -- Godot expects 4-space indentation in .gd files.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'gdscript',
    callback = function()
      vim.bo.expandtab = true
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.softtabstop = 4
    end,
  })

  -- Format .gd files with gdscript-formatter on save (overrides the generic
  -- LSP format autocmd above, since Godot's LSP doesn't format).
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '*.gd',
    callback = function(args)
      local file = vim.fn.shellescape(vim.api.nvim_buf_get_name(args.buf))
      vim.fn.system('gdscript-formatter --reorder-code ' .. file)
      vim.cmd('silent! checktime')
    end,
  })

  -- C# via roslyn.nvim (Microsoft's official Roslyn LSP, same engine as
  -- VSCode's C# Dev Kit). Auto-attaches when a .cs buffer is opened inside
  -- a project containing a .sln/.slnx/.csproj. The plugin shells out to the
  -- `Microsoft.CodeAnalysis.LanguageServer` binary provided by roslyn-ls.
  require('roslyn').setup({
    config = {
      capabilities = cmp_capabilities,
    },
  })

  -- Format .cs files with csharpier on save (Roslyn LSP doesn't format).
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '*.cs',
    callback = function(args)
      local file = vim.fn.shellescape(vim.api.nvim_buf_get_name(args.buf))
      vim.fn.system('csharpier format ' .. file)
      vim.cmd('silent! checktime')
    end,
  })
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, args.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, opts)
  end,
})

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

-- nvim-tree
require('nvim-tree').setup {
  view = {
    width = 30,
    number = true,
    relativenumber = true,
  },
  filters = { dotfiles = false },
}
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })
vim.keymap.set('n', '<leader>o', ':NvimTreeFocus<CR>', { desc = 'Focus file tree' })

-- lualine
require('lualine').setup {
  options = {
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

-- indent-blankline
require('ibl').setup {
  indent = { char = '│' },
  scope = { enabled = true, show_start = false, show_end = false },
}

-- Comment.nvim
require('Comment').setup()

-- gitsigns
require('gitsigns').setup()

-- DAP (Debug Adapter Protocol)
if nixCats('debug') then
  local dap = require('dap')
  local dapui = require('dapui')

  dapui.setup()

  -- codelldb adapter (lldb-dap fallback)
  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = 'lldb-dap',
      args = { '--port', '${port}' },
    },
  }

  dap.configurations.zig = {
    {
      name = 'Launch',
      type = 'codelldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/zig-out/bin/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = function()
        local input = vim.fn.input('Args: ')
        local args = {}
        for arg in input:gmatch('%S+') do
          table.insert(args, arg)
        end
        return args
      end,
    },
  }

  dap.configurations.c = dap.configurations.zig
  dap.configurations.cpp = dap.configurations.zig

  -- Godot DAP adapter — Godot editor exposes a debug server on TCP 6006
  -- when a project is open.
  if nixCats('godot') then
    dap.adapters.godot = {
      type = 'server',
      host = '127.0.0.1',
      port = 6006,
    }
    dap.configurations.gdscript = {
      {
        type = 'godot',
        request = 'launch',
        name = 'Launch scene',
        project = '${workspaceFolder}',
        launch_scene = true,
      },
    }

    -- C# debugging via netcoredbg. Godot launches the C# runtime in-process,
    -- so the typical workflow is: start Godot in debug mode, then attach
    -- netcoredbg to the running godot PID.
    dap.adapters.coreclr = {
      type = 'executable',
      command = 'netcoredbg',
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Attach to Godot',
        request = 'attach',
        processId = require('dap.utils').pick_process,
      },
    }
  end

  -- Auto open/close DAP UI
  dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
  dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
  dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

  -- Keybindings
  vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
  vim.keymap.set('n', '<leader>dB', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end, { desc = 'Conditional breakpoint' })
  vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue / Start' })
  vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Step over' })
  vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step into' })
  vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = 'Step out' })
  vim.keymap.set('n', '<leader>dr', dap.restart, { desc = 'Restart' })
  vim.keymap.set('n', '<leader>dx', dap.terminate, { desc = 'Terminate' })
  vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Toggle DAP UI' })
end
