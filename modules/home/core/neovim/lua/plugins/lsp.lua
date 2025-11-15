return {
  'neovim/nvim-lspconfig',
  config = function()
    vim.lsp.config.lua_ls = {
      cmd = { 'lua-language-server' },
    }
    vim.lsp.enable('lua_ls')

    vim.lsp.config.nixd = {
      cmd = { 'nixd' },
    }
    vim.lsp.enable('nixd')
  end
}
