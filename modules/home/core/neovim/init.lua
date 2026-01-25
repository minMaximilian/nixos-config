require('nixCatsUtils').setup {
  non_nix_value = true,
}

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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
vim.o.ignorecase = true
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

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>h', builtin.help_tags, { desc = 'Help tags' })

-- Treesitter (using new native vim.treesitter API)
vim.treesitter.language.register('bash', 'zsh')
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldenable = false

-- LSP
vim.lsp.config.lua_ls = { cmd = { 'lua-language-server' } }
vim.lsp.enable('lua_ls')

vim.lsp.config.nixd = { cmd = { 'nixd' } }
vim.lsp.enable('nixd')

vim.lsp.config.zls = { cmd = { 'zls' } }
vim.lsp.enable('zls')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.signatureHelpProvider then
      vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { buffer = args.buf })
    end
  end,
})

-- nvim-tree
require('nvim-tree').setup {
  view = { width = 30 },
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
