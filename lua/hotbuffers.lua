local M = {}
M.hotkeys = { "1", "2", "3", "4", "5" }
M.hotbufs = {}
--------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------

local function shortname(bufnr)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  return (name == "" and "[No Name]") or name
end

local function cleanup()
  for _, key in pairs(M.hotkeys) do
    local bufnr = M.hotbufs[key]
    if bufnr and (not vim.api.nvim_buf_is_valid(bufnr)) then
      M.hotbufs[key] = nil
    end
  end
end

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

  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Add current buffer to specific slot n (replace if needed)
--------------------------------------------------------------------
function M.add_current_to(key)
  if not is_hotkeys(key) then
    return
    -- TODO: add additional hotkeys behavior here
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- remove duplicates
  for hotkey, assigned_bufnr in pairs(M.hotbufs) do
    if assigned_bufnr == bufnr then
      M.hotbufs[hotkey] = nil
    end
  end

  M.hotbufs[key] = bufnr
  vim.notify(string.format("Set key %s → %s", key, shortname(bufnr)))
  M.refresh_statusline()
end

function M.swap_current_with(target_key)
  if not is_hotkeys(target_key) then
    return
  end

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

  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Jump to Nth hot buffer
--------------------------------------------------------------------
function M.goto_hot(key)
  local bufnr = M.hotbufs[key]
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_set_current_buf(bufnr)
  end
  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Dehot Buffer
--------------------------------------------------------------------
function M.dehot(key)
  M.hotbufs[key] = nil
  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Dehot Current Buffer
--------------------------------------------------------------------
function M.dehot_current()
  cleanup()
  local current_bufnr = vim.api.nvim_get_current_buf()
  for key, bufnr in pairs(M.hotbufs) do
    if current_bufnr == bufnr then
      M.hotbufs[key] = nil
    end
  end
  M.refresh_statusline()
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
  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Statusline Display
--------------------------------------------------------------------
function M.statusline()
  cleanup()
  local parts = {}
  for _, key in pairs(M.hotkeys) do
    local bufnr = M.hotbufs[key]
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
  vim.o.statusline = "%!v:lua.require'hotbuffers'.statusline()"
end

--------------------------------------------------------------------
-- Setup / Keymaps
--------------------------------------------------------------------
function M.setup(hotkeys)
  if hotkeys then
    M.hotkeys = hotkeys
  end

  for _, key in pairs(M.hotkeys) do
    vim.keymap.set("n", string.format("<M-%s>", key), function()
      M.goto_hot(key)
    end, { desc = "Go to hot buffer " .. key })

    vim.keymap.set("n", string.format("<M-h>%s", key), function()
      M.swap_current_with(key)
    end, { desc = "Assign current buffer to hot slot " .. key })
  end

  vim.keymap.set("n", "<M-h>a", M.add_current, { desc = "Add current buffer to next free hot slot" })
  vim.keymap.set("n", "<M-x>", M.dehot_current, { desc = "Dehot current buffer" })
  vim.keymap.set("n", "<leader>hx", M.close_non_hot_buffers, { desc = "Close all non-hot buffers" })

  vim.api.nvim_create_autocmd("BufWipeout", {
    callback = function()
      cleanup()
    end
  })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
      -- Automatically add the current buffer to hot buffers when opened
      if vim.api.nvim_buf_get_name(0) == "" then return end
      require("hotbuffers").add_current()
    end,
  })

  M.refresh_statusline()
end

return M
