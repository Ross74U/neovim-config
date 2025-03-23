-- Utility functions

local M = {}

-- Function to check if a command exists
M.command_exists = function(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Print a notification with consistent styling
M.notify = function(msg, level, opts)
  level = level or vim.log.levels.INFO
  opts = opts or {}
  vim.notify(msg, level, {
    title = opts.title or "Neovim",
    icon = opts.icon,
  })
end

return M
