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

local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('lua_ls', { capabilities = cmp_capabilities })
vim.lsp.enable('lua_ls')

vim.lsp.config('nixd', { capabilities = cmp_capabilities })
vim.lsp.enable('nixd')

vim.lsp.config('zls', { capabilities = cmp_capabilities })
vim.lsp.enable('zls')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, opts)
  end,
})

-- nvim-cmp (completion)
local cmp = require('cmp')
local luasnip = require('luasnip')

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip', keyword_length = 2 },
  }, {
    { name = 'buffer', keyword_length = 3 },
    { name = 'path' },
  }),
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
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
