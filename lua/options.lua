-- Basic Neovim settings
-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Basic settings
vim.opt.colorcolumn = "81"        -- Color column
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Show relative line numbers
vim.opt.termguicolors = true      -- Enable 24-bit RGB colors
vim.opt.shiftwidth = 2            -- Number of spaces for indentation
vim.opt.tabstop = 2               -- Number of spaces a tab counts for
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.smartindent = true        -- Smart auto-indenting
vim.opt.wrap = false              -- Don't wrap lines
vim.opt.ignorecase = true         -- Ignore case when searching
vim.opt.smartcase = true          -- Override ignorecase when search includes uppercase
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.splitbelow = true         -- Split below by default
vim.opt.splitright = true         -- Split right by default
vim.opt.showmode = false          -- Don't show mode in command line
vim.opt.scrolloff = 4             -- Start scrolling when 8 lines from edge
vim.opt.signcolumn = "yes"

-- Configure LSP diagnostic appearance (minimal)
vim.diagnostic.config({
  virtual_text = {
    prefix = '●',
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

-- status line initial empty value to ensure it is drawn even if hotbuffers isn't loaded properly
vim.o.laststatus = 3   -- always show a statusline
vim.o.statusline = " " -- ensure it's never empty
