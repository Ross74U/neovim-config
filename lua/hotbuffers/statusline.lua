local M = {}

--------------------------------------------------------------------
-- Statusline Display
--------------------------------------------------------------------

local function shortname(bufnr)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  return (name == "" and "[No Name]") or name
end

function M.statusline()
  local hotbuffers = require("hotbuffers.hotbuffers")
  hotbuffers.cleanup()

  local parts = {}
  for _, key in pairs(hotbuffers.hotkeys) do
    local bufnr = hotbuffers.hotbufs[key]
    local hl = key and (bufnr == vim.api.nvim_get_current_buf()) and "%#PmenuSel#" or "%#StatusLine#"
    if bufnr then
      table.insert(parts, string.format("%s[%s:%s]", hl, key, shortname(bufnr)))
    else
      table.insert(parts, string.format("%s[ %s:— ]", hl, key))
    end
  end
  return table.concat(parts, "       ")
end

function M.refresh_statusline()
  vim.o.statusline = "%!v:lua.require'hotbuffers.statusline'.statusline()"
end

return M
