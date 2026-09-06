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

