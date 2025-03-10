-- init.lua for Neovim
-- A configuration with NvimTree, buffer handling, Telescope
-- Uses default Neovim theme and Lazy plugin manager

-- Basic settings
vim.g.mapleader = " " -- Set leader key to space
vim.opt.number = true -- Line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true -- Highlight current line
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.smartindent = true -- Auto indent new lines
vim.opt.termguicolors = true -- True color support
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true -- Override ignorecase if search has uppercase
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right
vim.opt.timeoutlen = 300 -- Time to wait for a mapped sequence to complete (ms)
vim.opt.updatetime = 300 -- Faster completion
vim.opt.signcolumn = "yes" -- Always show the signcolumn
vim.opt.scrolloff = 8 -- Lines of context
vim.opt.sidescrolloff = 8 -- Columns of context

-- Bootstrap Lazy plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup with Lazy
require("lazy").setup({
  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        hijack_cursor = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
          ignore = true,
        },
        actions = {
          open_file = {
            resize_window = true,
            quit_on_open = false,
          },
        },
      })
    end,
  },
  
  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim", 
        build = "make"
      }
    },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          layout_config = {
            horizontal = {
              width = 0.8,
              height = 0.8,
            },
          },
          file_ignore_patterns = {"node_modules", ".git", "dist"},
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })
      -- Load telescope extensions
      require("telescope").load_extension("fzf")
    end,
  },
  
  -- Buffer handling
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          numbers = "none",
          close_command = function(bufnum)
            require("bufdelete").bufdelete(bufnum, true)
          end,
          right_mouse_command = function(bufnum)
            require("bufdelete").bufdelete(bufnum, true)
          end,
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          buffer_close_icon = "",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 18,
          max_prefix_length = 15,
          tab_size = 18,
          diagnostics = false,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "thin",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
        }
      })
    end,
  },
  
  -- Better buffer deletion
  {
    "famiu/bufdelete.nvim",
  },
  
  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto", -- Uses default theme based on vim colorscheme
          component_separators = { left = "", right = ""},
          section_separators = { left = "", right = ""},
          disabled_filetypes = {},
          always_divide_middle = true,
        },
        sections = {
          lualine_a = {"mode"},
          lualine_b = {"branch", "diff", "diagnostics"},
          lualine_c = {"filename"},
          lualine_x = {"encoding", "fileformat", "filetype"},
          lualine_y = {"progress"},
          lualine_z = {"location"}
        },
      })
    end,
  },
  
  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        disable_filetype = { "TelescopePrompt" },
      })
    end,
  },
  
  -- Comments
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
})

-- NvChad-like Keybindings

-- Helper function for setting keymaps
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Basic keybindings
map("n", "<C-h>", "<C-w>h") -- Navigate left window
map("n", "<C-j>", "<C-w>j") -- Navigate down window
map("n", "<C-k>", "<C-w>k") -- Navigate up window
map("n", "<C-l>", "<C-w>l") -- Navigate right window

map("n", "<C-Up>", ":resize -2<CR>") -- Resize window up
map("n", "<C-Down>", ":resize +2<CR>") -- Resize window down
map("n", "<C-Left>", ":vertical resize -2<CR>") -- Resize window left
map("n", "<C-Right>", ":vertical resize +2<CR>") -- Resize window right

-- Leader-based keybindings (NvChad-like)
-- File operations
map("n", "<leader>w", ":w<CR>") -- Save
map("n", "<leader>q", ":q<CR>") -- Quit
map("n", "<leader>Q", ":qa!<CR>") -- Force quit all

-- NvimTree
map("n", "<leader>e", ":NvimTreeToggle<CR>") -- Toggle file explorer
map("n", "<leader>o", ":NvimTreeFocus<CR>") -- Focus file explorer

-- Buffer management
map("n", "<leader>x", ":Bdelete<CR>") -- Close buffer
map("n", "<leader>X", ":Bdelete!<CR>") -- Force close buffer
map("n", "<leader>1", ":BufferLineGoToBuffer 1<CR>") -- Go to buffer 1
map("n", "<leader>2", ":BufferLineGoToBuffer 2<CR>") -- Go to buffer 2
map("n", "<leader>3", ":BufferLineGoToBuffer 3<CR>") -- Go to buffer 3
map("n", "<leader>4", ":BufferLineGoToBuffer 4<CR>") -- Go to buffer 4
map("n", "<leader>5", ":BufferLineGoToBuffer 5<CR>") -- Go to buffer 5
map("n", "<leader>6", ":BufferLineGoToBuffer 6<CR>") -- Go to buffer 6
map("n", "<leader>7", ":BufferLineGoToBuffer 7<CR>") -- Go to buffer 7
map("n", "<leader>8", ":BufferLineGoToBuffer 8<CR>") -- Go to buffer 8
map("n", "<leader>9", ":BufferLineGoToBuffer 9<CR>") -- Go to buffer 9
map("n", "<leader>$", ":BufferLineGoToBuffer -1<CR>") -- Go to last buffer
map("n", "<Tab>", ":BufferLineCycleNext<CR>") -- Next buffer
map("n", "<S-Tab>", ":BufferLineCyclePrev<CR>") -- Previous buffer

-- Telescope keybindings
map("n", "<leader>ff", ":Telescope find_files<CR>") -- Find files
map("n", "<leader>fg", ":Telescope live_grep<CR>") -- Find text
map("n", "<leader>fb", ":Telescope buffers<CR>") -- Find buffers
map("n", "<leader>fh", ":Telescope help_tags<CR>") -- Find help
map("n", "<leader>fo", ":Telescope oldfiles<CR>") -- Find recent files
map("n", "<leader>fc", ":Telescope colorscheme<CR>") -- Find colorscheme
map("n", "<leader>f.", ":Telescope find_files hidden=true<CR>") -- Find hidden files
map("n", "<leader>fr", ":Telescope registers<CR>") -- Find registers
map("n", "<leader>fm", ":Telescope marks<CR>") -- Find marks

-- Window management
map("n", "<leader>sv", ":vsplit<CR>") -- Split vertically
map("n", "<leader>sh", ":split<CR>") -- Split horizontally
map("n", "<leader>se", "<C-w>=") -- Equal width windows
map("n", "<leader>sx", ":close<CR>") -- Close window

-- General
map("n", "<leader>h", ":nohlsearch<CR>") -- Clear highlights
map("n", "<leader>n", ":set relativenumber!<CR>") -- Toggle relative numbers

-- Auto commands
vim.cmd [[
  " Highlight yanked text
  augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
  augroup END
]]

-- Auto-commands in Lua (alternative to vimscript)
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line
    if line("'\"") > 0 and line("'\"") <= line("$") then
      vim.cmd("normal! g`\"")
    end
  end,
})

-- Disable netrw (recommended for nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
