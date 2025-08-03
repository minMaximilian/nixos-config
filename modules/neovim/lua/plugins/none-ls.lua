local lsp_format_augroup = vim.api.nvim_create_augroup("LspFormat", { clear = true })

return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.nixpkgs_fmt,
        null_ls.builtins.diagnostics.statix,
        null_ls.builtins.formatting.prettier,
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = lsp_format_augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false, bufnr = bufnr })
            end,
          })
        end
      end,
    })
    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, {})
  end,
} 