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

local cmp_capabilities = require('blink.cmp').get_lsp_capabilities()

vim.lsp.config('lua_ls', { capabilities = cmp_capabilities })
vim.lsp.enable('lua_ls')

vim.lsp.config('nixd', { capabilities = cmp_capabilities })
vim.lsp.enable('nixd')

vim.lsp.config('zls', { capabilities = cmp_capabilities })
vim.lsp.enable('zls')

vim.lsp.config('ols', { capabilities = cmp_capabilities })
vim.lsp.enable('ols')

vim.lsp.config('glsl_analyzer', { capabilities = cmp_capabilities })
vim.lsp.enable('glsl_analyzer')

-- Godot / GDScript
--
-- Godot's editor itself ships the GDScript language server. When the editor
-- is open with a project loaded, it listens on TCP 127.0.0.1:6005 (LSP) and
-- 127.0.0.1:6006 (DAP). nvim-lspconfig ships a `gdscript` config that
-- connects to that port; we just enable it. The server attaches when a `.gd`
-- buffer is opened inside a project containing `project.godot`.
if nixCats('godot') then
  vim.filetype.add({
    extension = {
      gd = 'gdscript',
      tscn = 'gdresource',
      tres = 'gdresource',
      gdshader = 'gdshader',
    },
  })

  vim.lsp.config('gdscript', {
    capabilities = cmp_capabilities,
    on_attach = function(client)
      -- Godot's LSP doesn't implement textDocument/didClose; suppress to
      -- avoid spurious errors when buffers are closed.
      local _notify = client.notify
      client.notify = function(method, params)
        if method == 'textDocument/didClose' then return true end
        return _notify(method, params)
      end
    end,
  })
  vim.lsp.enable('gdscript')

  -- Godot expects 4-space indentation in .gd files.
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'gdscript',
    callback = function()
      vim.bo.expandtab = true
      vim.bo.tabstop = 4
      vim.bo.shiftwidth = 4
      vim.bo.softtabstop = 4
    end,
  })

  -- Format .gd files with gdscript-formatter on save (overrides the generic
  -- LSP format autocmd above, since Godot's LSP doesn't format).
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '*.gd',
    callback = function(args)
      local file = vim.fn.shellescape(vim.api.nvim_buf_get_name(args.buf))
      vim.fn.system('gdscript-formatter --reorder-code ' .. file)
      vim.cmd('silent! checktime')
    end,
  })

  -- C# via roslyn.nvim (Microsoft's official Roslyn LSP, same engine as
  -- VSCode's C# Dev Kit). Auto-attaches when a .cs buffer is opened inside
  -- a project containing a .sln/.slnx/.csproj. The plugin shells out to the
  -- `Microsoft.CodeAnalysis.LanguageServer` binary provided by roslyn-ls.
  require('roslyn').setup({
    config = {
      capabilities = cmp_capabilities,
    },
  })

  -- Format .cs files with csharpier on save (Roslyn LSP doesn't format).
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '*.cs',
    callback = function(args)
      local file = vim.fn.shellescape(vim.api.nvim_buf_get_name(args.buf))
      vim.fn.system('csharpier format ' .. file)
      vim.cmd('silent! checktime')
    end,
  })
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, args.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, opts)
  end,
})

