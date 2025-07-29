-- Use the nixCats wrapper for lazy.nvim.
-- NOTE: This is the core of the nixCats integration. It's like the normal
-- require("lazy").setup(), but it automatically provides all the plugins
-- you defined in your Nix configuration.
require('nixCatsUtils.lazyCat').setup(nixCats.pawsible { 'allPlugins', 'start', 'lazy.nvim' }, {
  -- We don't need to list plugins here because Nix is providing them.
  -- We can, however, configure them by referring to them by their name.
  {
    "folke/tokyonight.nvim",
    -- The `config` function will run after the plugin is loaded.
    -- lazy.nvim is smart enough to load themes first.
    config = function()
      vim.cmd.colorscheme "tokyonight"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- These two lines are CRITICAL for a read-only Nix environment.
        -- They tell treesitter to NOT try and install anything itself.
        ensure_installed = {},
        auto_install = false,
        highlight = {
          enable = true,
        },
      })
    end,
  },

  -- This line will automatically load any .lua files you add to the `lua/plugins/` directory.
  -- This is the recommended way to keep your configuration organized.
  { import = 'plugins' },
}, {}) -- The final {} is for lazy.nvim options, which we don't need.

-- Basic Neovim options can go here, as they don't depend on plugins.
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
