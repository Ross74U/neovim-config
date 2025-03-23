-- UI related plugins
return {
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
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "#000000" })         -- Non-current windows
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
      vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "#000000" })   -- NvimTree background
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

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({})
    end,
  },

  -- Bufferline for tab management
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
}
