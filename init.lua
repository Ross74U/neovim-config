-- init.lua for Neovim
-- A minimalistic configuration with NvimTree, tabs/buffers, Telescope, 
-- syntax highlighting, and autocompletion

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.termguicolors = true  -- Enable 24-bit RGB colors
vim.opt.shiftwidth = 2        -- Number of spaces for indentation
vim.opt.tabstop = 2           -- Number of spaces a tab counts for
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.smartindent = true    -- Smart auto-indenting
vim.opt.wrap = false          -- Don't wrap lines
vim.opt.ignorecase = true     -- Ignore case when searching
vim.opt.smartcase = true      -- Override ignorecase when search includes uppercase
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.splitbelow = true     -- Split below by default
vim.opt.splitright = true     -- Split right by default
vim.opt.showmode = false      -- Don't show mode in command line
vim.opt.scrolloff = 8         -- Start scrolling when 8 lines from edge
vim.opt.updatetime = 300      -- Faster completion

-- Bootstrap lazy.nvim
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

-- Plugin specifications
require("lazy").setup({
  -- Rose Pine with persistent black background
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      -- First load Rose Pine with default settings
      require("rose-pine").setup({
        variant = "main",
      })
      -- Set the colorscheme
      vim.cmd("colorscheme rose-pine")
      -- Override backgrounds to black for both active and inactive windows
      vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" }) -- Non-current windows
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
      vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "#000000" }) -- NvimTree background
      vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "#000000" }) -- NvimTree inactive
      -- Set background for file explorer specifically
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "NvimTree",
        callback = function()
          vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
          vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
        end
      })
      -- Keep background black when switching buffers
      vim.api.nvim_create_autocmd("WinEnter", {
        callback = function()
          vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
          vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })
        end
      })
      vim.opt.background = "dark"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        respect_buf_cwd = true,
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
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
      })
    end,
  },

  -- Bufferline for tab management
  {
    "akinsho/bufferline.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "thin",
          always_show_bufferline = true,
          show_buffer_close_icons = true,
          show_close_icon = false,
          color_icons = true,
        },
      })
    end,
  },

  -- Telescope for fuzzy finding
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git" },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      require("telescope").load_extension("fzf")
    end,
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "python", "c", "cpp", "javascript", "typescript", "html", "css", 
          "json", "bash", "markdown", "yaml", "rust", "go"
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "pyright", "clangd", "ts_ls", "html", "cssls", "jsonls",
        },
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      
      -- Set up LSP servers
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
      
      -- Configure pyright to work with virtual environments
      lspconfig.pyright.setup({
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })
      
      lspconfig.clangd.setup({})
      lspconfig.ts_ls.setup({})
      lspconfig.html.setup({})
      lspconfig.cssls.setup({})
      lspconfig.jsonls.setup({})

      -- Global LSP key mappings
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to References" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      require("luasnip.loaders.from_vscode").lazy_load()
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "onedark",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
      })
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
})

-- Key mappings (NvChad-like)
-- File explorer
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle NvimTree" })
vim.keymap.set("n", "<leader>o", ":NvimTreeFocus<CR>", { silent = true, desc = "Focus NvimTree" })

-- Buffer navigation
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Previous buffer" })

-- Telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true, desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { silent = true, desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { silent = true, desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { silent = true, desc = "Help tags" })
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<CR>", { silent = true, desc = "Recent files" })

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

-- Define compact diagnostic symbols
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
