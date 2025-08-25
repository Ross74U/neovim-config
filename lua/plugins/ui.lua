-- UI related plugins
return {
  -- Bufferline for tab management
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "main", -- auto, main, moon, or dawn
        dark_variant = "main",
        dim_inactive_windows = false,
        extend_background_behind_borders = true,
        styles = {
          bold = true,
          italic = true,
          transparency = true,
        },
      })
      vim.cmd("colorscheme rose-pine")

      -- Override background to black
      vim.cmd("highlight Normal guibg=#000000")
      vim.cmd("highlight NormalNC guibg=#000000")
      vim.cmd("highlight SignColumn guibg=#000000")
      vim.cmd("highlight EndOfBuffer guibg=#000000")
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "thin",
          always_show_bufferline = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          color_icons = true,
        },
        highlights = {
          background = {
            bg = "#000000",
          },
          buffer_selected = {
            bg = "#000000",
          },
          buffer_visible = {
            bg = "#000000",
          },
          fill = {
            bg = "#000000",
          },
        },
      })
    end,
  },
}
