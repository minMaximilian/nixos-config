require('nixCatsUtils').setup {
  non_nix_value = true,
}

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.hidden = true
vim.opt.swapfile = true
vim.opt.undofile = true

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.scrolloff = 8
vim.opt.cursorline = true

vim.opt.wrap = false
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.keymap.set("n", "<leader>w", "<cmd>wa<cr>", { desc = "Save all buffers" })
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Focus left window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Focus right window" })

vim.keymap.set("n", "<Up>", "<nop>", { desc = "Disable up arrow" })
vim.keymap.set("n", "<Down>", "<nop>", { desc = "Disable down arrow" })
vim.keymap.set("n", "<Left>", "<nop>", { desc = "Disable left arrow" })
vim.keymap.set("n", "<Right>", "<nop>", { desc = "Disable right arrow" })

vim.keymap.set("i", "<Up>", "<nop>", { desc = "Disable up arrow" })
vim.keymap.set("i", "<Down>", "<nop>", { desc = "Disable down arrow" })
vim.keymap.set("i", "<Left>", "<nop>", { desc = "Disable left arrow" })
vim.keymap.set("i", "<Right>", "<nop>", { desc = "Disable right arrow" })

vim.keymap.set("v", "<Up>", "<nop>", { desc = "Disable up arrow" })
vim.keymap.set("v", "<Down>", "<nop>", { desc = "Disable down arrow" })
vim.keymap.set("v", "<Left>", "<nop>", { desc = "Disable left arrow" })
vim.keymap.set("v", "<Right>", "<nop>", { desc = "Disable right arrow" })

vim.keymap.set("i", "<Caps_Lock>", "<Esc>", { desc = "Caps Lock to Escape" })
vim.keymap.set("v", "<Caps_Lock>", "<Esc>", { desc = "Caps Lock to Escape" })
vim.keymap.set("c", "<Caps_Lock>", "<Esc>", { desc = "Caps Lock to Escape" })

vim.keymap.set("n", "<leader>y", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste from clipboard" })

local function getlockfilepath()
  if require('nixCatsUtils').isNixCats and type(nixCats.settings.unwrappedCfgPath) == 'string' then
    return nixCats.settings.unwrappedCfgPath .. '/lazy-lock.json'
  else
    return vim.fn.stdpath 'config' .. '/lazy-lock.json'
  end
end
local lazyOptions = {
  lockfile = getlockfilepath(),
  lazy = {
    show = false,
  },
}

require('nixCatsUtils.lazyCat').setup(nixCats.pawsible { 'allPlugins', 'start', 'lazy.nvim' }, {
  { 'williamboman/mason-lspconfig.nvim', enabled = require('nixCatsUtils').lazyAdd(true, false) },
  { 'williamboman/mason.nvim', enabled = require('nixCatsUtils').lazyAdd(true, false) },
  {
    'nvim-treesitter/nvim-treesitter',
    build = require('nixCatsUtils').lazyAdd ':TSUpdate',
    opts_extend = require('nixCatsUtils').lazyAdd(nil, false),
    opts = {
      ensure_installed = require('nixCatsUtils').lazyAdd({ 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'zig' }, false),
      auto_install = require('nixCatsUtils').lazyAdd(false, false),
    },
  },
  {
    'folke/lazydev.nvim',
    opts = {
      library = {
        { path = (nixCats.nixCatsPath or '') .. '/lua', words = { 'nixCats' } },
      },
    },
  },
  { import = 'plugins' },
}, lazyOptions)
