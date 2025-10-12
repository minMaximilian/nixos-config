local M = {}

M.isNixCats = vim.g[ [[nixCats-special-rtp-entry-nixCats]] ] ~= nil

function M.setup(v)
  if not M.isNixCats then
    local nixCats_default_value
    if type(v) == "table" and type(v.non_nix_value) == "boolean" then
      nixCats_default_value = v.non_nix_value
    else
      nixCats_default_value = true
    end
    local mk_with_meta = function(tbl)
      return setmetatable(tbl, {
        __call = function(_, attrpath)
          local strtable = {}
          if type(attrpath) == "table" then
            strtable = attrpath
          elseif type(attrpath) == "string" then
            for key in attrpath:gmatch("([^%.]+)") do
              table.insert(strtable, key)
            end
          else
            print("function requires a table of strings or a dot separated string")
            return
          end
          return vim.tbl_get(tbl, unpack(strtable));
        end
      })
    end
    package.preload['nixCats'] = function()
      local ncsub = {
        get = function(_) return nixCats_default_value end,
        cats = mk_with_meta({
          nixCats_config_location = vim.fn.stdpath('config'),
          wrapRc = false,
        }),
        settings = mk_with_meta({
          nixCats_config_location = vim.fn.stdpath('config'),
          configDirName = os.getenv("NVIM_APPNAME") or "nvim",
          wrapRc = false,
        }),
        petShop = mk_with_meta({}),
        extra = mk_with_meta({}),
        pawsible = mk_with_meta({
          allPlugins = {
            start = {},
            opt = {},
          },
        }),
        configDir = vim.fn.stdpath('config'),
        packageBinPath = os.getenv('NVIM_WRAPPER_PATH_NIX') or vim.v.progpath
      }
      return setmetatable(ncsub, { __call = function(_, cat) return ncsub.get(cat) end })
    end
    _G.nixCats = require('nixCats')
  end
end

function M.enableForCategory(v, default)
  if M.isNixCats or default == nil then
    if nixCats(v) then
      return true
    else
      return false
    end
  else
    return default
  end
end

function M.getCatOrDefault(v, default)
  if M.isNixCats then
    return nixCats(v)
  else
    return default
  end
end

function M.lazyAdd(v, o)
  if M.isNixCats then
    return o
  else
    return v
  end
end

return M
