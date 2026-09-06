-- DAP (Debug Adapter Protocol)
if nixCats('debug') then
  local dap = require('dap')
  local dapui = require('dapui')

  dapui.setup()

  -- codelldb adapter (lldb-dap fallback)
  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = 'lldb-dap',
      args = { '--port', '${port}' },
    },
  }

  dap.configurations.zig = {
    {
      name = 'Launch',
      type = 'codelldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/zig-out/bin/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = function()
        local input = vim.fn.input('Args: ')
        local args = {}
        for arg in input:gmatch('%S+') do
          table.insert(args, arg)
        end
        return args
      end,
    },
  }

  dap.configurations.c = dap.configurations.zig
  dap.configurations.cpp = dap.configurations.zig

  -- Godot DAP adapter — Godot editor exposes a debug server on TCP 6006
  -- when a project is open.
  if nixCats('godot') then
    dap.adapters.godot = {
      type = 'server',
      host = '127.0.0.1',
      port = 6006,
    }
    dap.configurations.gdscript = {
      {
        type = 'godot',
        request = 'launch',
        name = 'Launch scene',
        project = '${workspaceFolder}',
        launch_scene = true,
      },
    }

    -- C# debugging via netcoredbg. Godot launches the C# runtime in-process,
    -- so the typical workflow is: start Godot in debug mode, then attach
    -- netcoredbg to the running godot PID.
    dap.adapters.coreclr = {
      type = 'executable',
      command = 'netcoredbg',
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Attach to Godot',
        request = 'attach',
        processId = require('dap.utils').pick_process,
      },
    }
  end

  -- Auto open/close DAP UI
  dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
  dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
  dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

  -- Keybindings
  vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
  vim.keymap.set('n', '<leader>dB', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end, { desc = 'Conditional breakpoint' })
  vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue / Start' })
  vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Step over' })
  vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step into' })
  vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = 'Step out' })
  vim.keymap.set('n', '<leader>dr', dap.restart, { desc = 'Restart' })
  vim.keymap.set('n', '<leader>dx', dap.terminate, { desc = 'Terminate' })
  vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Toggle DAP UI' })
end
