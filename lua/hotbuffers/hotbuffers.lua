local M = {}
local statusline = require("hotbuffers.statusline")

--- @type table<number, string>
M.hotkeys = { "1", "2", "3", "4", "5" } -- sensible default

--- @type table<string, number>
M.hotbufs = {}

local function is_hotkeys(key)
  if type(key) ~= "string" then
    return false
  end
  for _, hotkey in pairs(M.hotkeys) do
    if hotkey == key then
      return true
    end
  end
end

--------------------------------------------------------------------
-- Add current buffer to next available slot
--------------------------------------------------------------------
function M.add_current()
  ---@type number
  local current_bufnr = vim.api.nvim_get_current_buf()

  -- skip if already hot
  for _, bufnr in pairs(M.hotbufs) do
    if bufnr == current_bufnr then
      return
    end
  end

  -- find a free slot
  for _, key in pairs(M.hotkeys) do
    if not M.hotbufs[key] then
      M.hotbufs[key] = current_bufnr
      return
    end
  end

  statusline.refresh_statusline()
end

--------------------------------------------------------------------
-- Add current buffer to specific slot n (replace if needed)
--------------------------------------------------------------------
function M.add_current_to(key)
  if not is_hotkeys(key) then
    return
    -- TODO: add additional hotkeys behavior here
  end

  ---@type number
  local bufnr = vim.api.nvim_get_current_buf()

  -- remove duplicates
  for hotkey, assigned_bufnr in pairs(M.hotbufs) do
    if assigned_bufnr == bufnr then
      M.hotbufs[hotkey] = nil
    end
  end

  M.hotbufs[key] = bufnr
  statusline.refresh_statusline()
end

function M.swap_current_with(target_key)
  if not is_hotkeys(target_key) then
    return
  end

  ---@type number
  local current_bufnr = vim.api.nvim_get_current_buf()
  local target_bufnr = M.hotbufs[target_key]

  local current_key = nil;
  for key, bufnr in pairs(M.hotbufs) do
    if bufnr == current_bufnr then
      current_key = key
      M.hotbufs[key] = nil
    end
  end

  if target_bufnr and current_key then
    M.hotbufs[current_key] = target_bufnr
  end
  M.hotbufs[target_key] = current_bufnr

  statusline.refresh_statusline()
end

--------------------------------------------------------------------
-- Jump to Nth hot buffer
--------------------------------------------------------------------
function M.goto_hot(key)
  local bufnr = M.hotbufs[key]
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_set_current_buf(bufnr)
  end
  statusline.refresh_statusline()
end

--------------------------------------------------------------------
-- Dehot Buffer
--------------------------------------------------------------------
function M.dehot(key)
  M.hotbufs[key] = nil
  statusline.refresh_statusline()
end

--------------------------------------------------------------------
-- Dehot Current Buffer
--------------------------------------------------------------------
function M.dehot_current()
  M.cleanup()
  ---@type number
  local current_bufnr = vim.api.nvim_get_current_buf()
  for key, bufnr in pairs(M.hotbufs) do
    if current_bufnr == bufnr then
      M.hotbufs[key] = nil
    end
  end
  statusline.refresh_statusline()
end

--------------------------------------------------------------------
-- Close all buffers that are NOT in hotbufs
--------------------------------------------------------------------
function M.close_non_hot_buffers()
  local hot_set = {}
  for _, bufnr in pairs(M.hotbufs) do
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      hot_set[bufnr] = true
    end
  end

  local closed_count = 0
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    -- Delete only normal listed buffers (skip hot ones)
    if vim.api.nvim_buf_is_valid(bufnr)
        and vim.fn.buflisted(bufnr) == 1
        and not hot_set[bufnr] then
      vim.api.nvim_buf_delete(bufnr, { force = false })
      closed_count = closed_count + 1
    end
  end

  vim.notify(string.format("Closed %d non-hot buffers", closed_count))
  statusline.refresh_statusline()
end

function M.cleanup()
  for _, key in pairs(M.hotkeys) do
    local bufnr = M.hotbufs[key]
    if bufnr and (not vim.api.nvim_buf_is_valid(bufnr)) then
      M.hotbufs[key] = nil
    end
  end
end

return M
