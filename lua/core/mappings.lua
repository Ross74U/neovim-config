-- Key mappings

-- File explorer
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle NvimTree" })
vim.keymap.set("n", "<leader>o", ":NvimTreeFocus<CR>", { silent = true, desc = "Focus NvimTree" })

-- Buffer navigation
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous buffer" })

-- Telescope
vim.keymap.set("n", "<leader>ff",
  ":Telescope find_files hidden=true find_command=rg,--files,--hidden,--glob,!**/.git/*<CR>",
  { silent = true, desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep hidden=true find_command=rg,--files,--hidden,--glob,!**/.git<CR>",
  { silent = true, desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers hidden=true find_command=rg,--files,--hidden,--glob,!**/.git<CR>",
  { silent = true, desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { silent = true, desc = "Help tags" })
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles hidden=true find_command=rg,--files,--hidden,--glob,!**/.git<CR>",
  { silent = true, desc = "Recent files" })
vim.keymap.set("n", "<leader>fr", ":Telescope resume<CR>", { silent = true, desc = "Recent files" })

-- Window navigation
vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", { silent = true, desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", { silent = true, desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", { silent = true, desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", { silent = true, desc = "Move to right window" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR><C-w>=", { silent = true, desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR><C-w>=", { silent = true, desc = "Decrease window height" })
vim.keymap.set("n", "<M-h>", "<cmd>vertical resize -2<CR>", { silent = true, desc = "Decrease window width" })
vim.keymap.set("n", "<M-l>", "<cmd>vertical resize +2<CR>", { silent = true, desc = "Increase window width" })

-- Otheir useful mappings
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true, desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true, desc = "Quit" })
vim.keymap.set("n", "<Esc>", ":noh<CR>", { silent = true, desc = "Clear highlights" })
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', '<M-j>', '10jzz', { noremap = true, silent = true })
vim.keymap.set('n', '<M-k>', '10kzz', { noremap = true, silent = true })

-- Open current buffer in vertical and horizontal split
vim.keymap.set('n', '<leader>vv', ':vsplit<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>hh', ':split<CR>', { noremap = true, silent = true })
-- Convert all splits to tabs
vim.keymap.set('n', '<leader>tt', '<C-w>T', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>cc', '<C-w>c', { noremap = true, silent = true, desc = "Close current split" })

-- LSP diagnostics
vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.open_float(0, { scope = "line" })
end, { silent = true, desc = "Show diagnostics" })

-- Toggle diagnostics on and off
vim.keymap.set('n', '<leader>td', function()
  local current_state = vim.diagnostic.is_disabled()
  if current_state then
    vim.diagnostic.enable()
    vim.notify("Diagnostics enabled", vim.log.levels.INFO)
  else
    vim.diagnostic.disable()
    vim.notify("Diagnostics disabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle diagnostics" })
