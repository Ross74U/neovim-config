local M = {}

-- cursors maps bufnrs to cursor positions in that bufnr
---@type table<number, CursorPos[]>
M.cursor_positions = {}

---@class CursorPos
---@field col number
---@field row number

--- insert pos into pos_arr so pos_arr stays sorted by row
--- if the same row is found, replace the existing one
--- pos_arr should not be a nil value at this point
--- @param pos_arr CursorPos[]
--- @param pos CursorPos
--- @return CursorPos[]
local function insert_sorted(pos_arr, pos)
  -- handle empty array
  if #pos_arr == 0 then
    table.insert(pos_arr, pos)
    return pos_arr
  end

  for i = 1, #pos_arr do
    local cur = pos_arr[i]
    if pos.row == cur.row then
      -- replace if same column
      pos_arr[i] = pos
      return pos_arr
    elseif pos.row < cur.row then
      -- insert before the current element to maintain order
      table.insert(pos_arr, i, pos)
      return pos_arr
    end
  end
  -- if pos.col is greater than all existing ones, append at the end
  table.insert(pos_arr, pos)
  return pos_arr
end

--- find a pos in pos_arr with row = pos.row, delete it
--- keeps pos_arr sorted and contiguous
--- @param pos_arr CursorPos[]
--- @param pos CursorPos
--- @return boolean
local function delete_pos(pos_arr, pos)
  for i = 1, #pos_arr do
    local cur = pos_arr[i]
    if cur.row == pos.row then
      table.remove(pos_arr, i)
      return true
    end
  end
  return false -- nothing matched
end


vim.fn.sign_define("SavedCursor", { text = "C", texthl = "WarningMsg" })




function M.toggle_current_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
  if not buftype == '' then return end

  local win = vim.api.nvim_get_current_win()
  ---@type number, number
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))

  -- initialized nil bufnr
  if M.cursor_positions[bufnr] == nil then
    table.insert(M.cursor_positions, bufnr, {})
  end

  if delete_pos(M.cursor_positions[bufnr], { row = row, col = col }) then
    vim.fn.sign_unplace("SavedCursorGroup", { buffer = bufnr, id = row })
    return
  end

  insert_sorted(M.cursor_positions[bufnr], { row = row, col = col })
  vim.fn.sign_place(row, "SavedCursorGroup", "SavedCursor", bufnr, { lnum = row, priority = 10 })
end

-- saves the current cursor position to the current bufnr
function M.save_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
  if not buftype == '' then return end

  local win = vim.api.nvim_get_current_win()
  ---@type number, number
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))

  -- initialized nil bufnr
  if M.cursor_positions[bufnr] == nil then
    table.insert(M.cursor_positions, bufnr, {})
  end

  insert_sorted(M.cursor_positions[bufnr], { row = row, col = col })
  vim.fn.sign_place(row, "SavedCursorGroup", "SavedCursor", bufnr, { lnum = row, priority = 10 })
end

-- delete the current cursor hovered row
function M.cursor_delete()
  local bufnr = vim.api.nvim_get_current_buf()
  if M.cursor_positions[bufnr] == nil or #M.cursor_positions[bufnr] == 0 then return end
  local win = vim.api.nvim_get_current_win()
  ---@type number
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))

  if delete_pos(M.cursor_positions[bufnr], { row = row, col = col }) then
    vim.fn.sign_unplace("SavedCursorGroup", { buffer = bufnr, id = row })
  end
end

-- jump to next saved cursor position
function M.cursor_next()
  local bufnr = vim.api.nvim_get_current_buf()
  if M.cursor_positions[bufnr] == nil or #M.cursor_positions[bufnr] == 0 then return end
  local win = vim.api.nvim_get_current_win()
  ---@type number
  local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
  local next_pos = nil
  for i = 1, #M.cursor_positions[bufnr], 1 do
    local pos = M.cursor_positions[bufnr][i]
    if pos.row > row then
      next_pos = pos
    end
  end
  if not next_pos then next_pos = M.cursor_positions[bufnr][1] end
  vim.api.nvim_win_set_cursor(0, { next_pos.row, next_pos.col })
end

-- jump to prev saved cursor position
function M.cursor_prev()
  local bufnr = vim.api.nvim_get_current_buf()
  if M.cursor_positions[bufnr] == nil or #M.cursor_positions[bufnr] == 0 then return end
  local win = vim.api.nvim_get_current_win()
  ---@type number
  local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
  local next_pos = nil
  for i = #M.cursor_positions[bufnr], 1, -1 do
    local pos = M.cursor_positions[bufnr][i]
    if pos.row < row then
      next_pos = pos
    end
  end
  if not next_pos then next_pos = M.cursor_positions[bufnr][#M.cursor_positions[bufnr]] end
  vim.api.nvim_win_set_cursor(0, { next_pos.row, next_pos.col })
end

-- clear all saved cursor positions of the current buffer
function M.clear_cursors()
  ---@type number
  local bufnr = vim.api.nvim_get_current_buf()
  M.cursor_positions[bufnr] = nil
  vim.fn.sign_unplace("SavedCursorGroup", { buffer = bufnr })
end

return M
