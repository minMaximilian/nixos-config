require('nixCatsUtils.lazyCat').setup(nixCats.pawsible { 'allPlugins', 'start', 'lazy.nvim' }, {
  -- This line imports the default LazyVim configuration.
  {
    'LazyVim/LazyVim',
    opts = {
      -- Set a default colorscheme.
      colorscheme = "tokyonight",
    }
  },

  -- The following plugins are disabled because we handle their dependencies with Nix.
}) 