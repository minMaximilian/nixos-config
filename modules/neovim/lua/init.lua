require('nixCatsUtils.lazyCat').setup(nixCats.pawsible { 'allPlugins', 'start', 'lazy.nvim' }, {
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = "tokyonight",
    }
  },
}) 