local M = {}

local hotbuffers = require("hotbuffers.hotbuffers")
local statusline = require("hotbuffers.statusline")
local cursors = require("hotbuffers.cursors")
--------------------------------------------------------------------
-- Setup / Keymaps
--------------------------------------------------------------------
function M.setup(hotkeys)
  if hotkeys then
    hotbuffers.hotkeys = hotkeys
  end

  for _, key in pairs(hotbuffers.hotkeys) do
    vim.keymap.set("n", string.format("<M-%s>", key), function()
      hotbuffers.goto_hot(key)
    end, { desc = "Go to hot buffer " .. key })

    vim.keymap.set("n", string.format("<M-h>%s", key), function()
      hotbuffers.swap_current_with(key)
    end, { desc = "Assign current buffer to hot slot " .. key })
  end


  vim.fn.sign_define("SavedCursor", { text = "C", texthl = "CurSearch" })
  vim.keymap.set("n", "<M-h>a", hotbuffers.add_current, { desc = "Add current buffer to next free hot slot" })
  vim.keymap.set("n", "<M-x>", hotbuffers.dehot_current, { desc = "Dehot current buffer" })
  vim.keymap.set("n", "<leader>hx", hotbuffers.close_non_hot_buffers, { desc = "Close all non-hot buffers" })
  vim.keymap.set("n", "<M-l>", cursors.toggle_current_cursor, { desc = "Save cursor" })
  vim.keymap.set("n", "<M-j>", cursors.cursor_next, { desc = "goto prev cursor" })
  vim.keymap.set("n", "<M-k>", cursors.cursor_prev, { desc = "goto next cursor " })
  vim.keymap.set("n", "<leader>lx", cursors.clear_cursors, { desc = "Clear all saved cursors in current buffer" })

  vim.api.nvim_create_autocmd("BufWipeout", {
    callback = function()
      hotbuffers.cleanup()
    end
  })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
      -- Automatically add the current buffer to hot buffers when opened
      if vim.api.nvim_buf_get_name(0) == "" then return end
      hotbuffers.add_current()
    end,
  })

  statusline.refresh_statusline()
end

return M
