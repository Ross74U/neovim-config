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
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { silent = true, desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { silent = true, desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true, desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true, desc = "Increase window width" })

-- Other useful mappings
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true, desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true, desc = "Quit" })
vim.keymap.set("n", "<Esc>", ":noh<CR>", { silent = true, desc = "Clear highlights" })

-- Open current buffer in vertical and horizontal split
vim.keymap.set('n', '<leader>vv', ':vsplit<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>hh', ':split<CR>', { noremap = true, silent = true })
-- Convert all splits to tabs (each window becomes its own tab)
vim.keymap.set('n', '<leader>tt', '<C-w>T', { noremap = true, silent = true })

-- LSP diagnostics
vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.open_float(0, { scope = "line" })
end, { silent = true, desc = "Show diagnostics" })
