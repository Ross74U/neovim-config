local M = {}

-- SETTINGS ---------------------------------------------------------
M.max_hot = 5  -- total slots
M.hotbufs = {} -- fixed-size list (nil or { bufnr = num })
for i = 1, M.max_hot do
  M.hotbufs[i] = nil
end

--------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------

local function shortname(bufnr)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  return (name == "" and "[No Name]") or name
end

-- remove invalid buffers from slots
local function cleanup()
  for i = 1, M.max_hot do
    local slot = M.hotbufs[i]
    if slot and (not vim.api.nvim_buf_is_valid(slot.bufnr)) then
      M.hotbufs[i] = nil
    end
  end
end

--------------------------------------------------------------------
-- Add current buffer to next available slot
--------------------------------------------------------------------
function M.add_current()
  cleanup()
  local current = vim.api.nvim_get_current_buf()

  -- skip if already hot
  for i = 1, M.max_hot do
    local slot = M.hotbufs[i]
    if slot and slot.bufnr == current then
      vim.notify("Buffer already marked hot")
      return
    end
  end

  -- find a free slot
  for i = 1, M.max_hot do
    if not M.hotbufs[i] then
      M.hotbufs[i] = { bufnr = current }
      return
    end
  end

  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Add current buffer to specific slot n (replace if needed)
--------------------------------------------------------------------
function M.add_current_to(n)
  if type(n) ~= "number" or n < 1 or n > M.max_hot then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- remove duplicates
  for i = 1, M.max_hot do
    if M.hotbufs[i] and M.hotbufs[i].bufnr == bufnr then
      M.hotbufs[i] = nil
    end
  end

  M.hotbufs[n] = { bufnr = bufnr }
  vim.notify(string.format("Set slot %d → %s", n, shortname(bufnr)))
  M.refresh_statusline()
end

function M.swap_current_with(n)
  if type(n) ~= "number" or n < 1 or n > M.max_hot then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local target_slot = M.hotbufs[n]

  local prev_slot_num = nil;
  for i = 1, M.max_hot do
    if M.hotbufs[i] and M.hotbufs[i].bufnr == bufnr then
      M.hotbufs[i] = nil
      prev_slot_num = i
    end
  end

  if target_slot then
    if prev_slot_num then
      M.hotbufs[prev_slot_num] = { bufnr = target_slot.bufnr }
    else
      for i = 1, M.max_hot do
        if not M.hotbufs[i] then
          M.hotbufs[i] = { bufnr = target_slot.bufnr }
          return
        end
      end
    end
  end

  M.hotbufs[n] = { bufnr = bufnr }
  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Jump to Nth hot buffer
--------------------------------------------------------------------
function M.goto_hot(n)
  cleanup()
  local slot = M.hotbufs[n]
  if slot and slot.bufnr and vim.api.nvim_buf_is_valid(slot.bufnr) then
    vim.api.nvim_set_current_buf(slot.bufnr)
  end
end

--------------------------------------------------------------------
-- Dehot Buffer
--------------------------------------------------------------------
function M.dehot(n)
  cleanup()
  M.hotbufs[n] = nil
  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Dehot Current Buffer
--------------------------------------------------------------------
function M.dehot_current()
  cleanup()
  local bufnr = vim.api.nvim_get_current_buf()
  for i, slot in ipairs(M.hotbufs) do
    if slot.bufnr == bufnr then
      M.hotbufs[i] = nil
    end
  end
  M.refresh_statusline()
end

--------------------------------------------------------------------
-- Close all buffers that are NOT in hotbufs
--------------------------------------------------------------------
function M.close_non_hot_buffers()
  local hot_set = {}
  for _, slot in ipairs(M.hotbufs) do
    if slot and slot.bufnr and vim.api.nvim_buf_is_valid(slot.bufnr) then
      hot_set[slot.bufnr] = true
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
  for i = 1, M.max_hot do
    local slot = M.hotbufs[i]
    local hl = slot and (slot.bufnr == vim.api.nvim_get_current_buf()) and "%#PmenuSel#" or "%#StatusLine#"
    if slot and slot.bufnr and vim.api.nvim_buf_is_valid(slot.bufnr) then
      table.insert(parts, string.format("%s[%d:%s]", hl, i, shortname(slot.bufnr)))
    else
      table.insert(parts, string.format("%s[ %d:— ]", hl, i))
    end
  end
  return table.concat(parts, " ")
end

function M.refresh_statusline()
  vim.o.statusline = "%!v:lua.require'hotbuffers'.statusline()"
end

--------------------------------------------------------------------
-- Setup / Keymaps
--------------------------------------------------------------------
function M.setup()
  for i = 1, M.max_hot do
    vim.keymap.set("n", string.format("<M-%d>", i), function()
      M.goto_hot(i)
    end, { desc = "Go to hot buffer " .. i })

    vim.keymap.set("n", string.format("<M-h>%d", i), function()
      M.swap_current_with(i)
    end, { desc = "Assign current buffer to hot slot " .. i })

    vim.keymap.set("n", string.format("<M-x>%d", i), function()
      M.dehot(i)
    end, { desc = "Assign current buffer to hot slot " .. i })
  end

  vim.keymap.set("n", "<M-h>a", M.add_current, { desc = "Add current buffer to next free hot slot" })
  vim.keymap.set("n", "<M-h>x", M.dehot_current, { desc = "Dehot current buffer" })

  vim.keymap.set("n", "<leader>hx", M.close_non_hot_buffers, { desc = "Close all non-hot buffers" })

  vim.api.nvim_create_autocmd("BufDelete", { callback = cleanup })

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
