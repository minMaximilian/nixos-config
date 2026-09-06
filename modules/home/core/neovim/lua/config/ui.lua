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

