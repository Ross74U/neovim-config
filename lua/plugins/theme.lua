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
        variant = "moon", -- auto, main, moon, or dawn
        dark_variant = "moon",
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
      vim.cmd("highlight StatusLine guibg=#000000 guifg=#aaaaaa")
      vim.cmd("highlight StatusLineNC guibg=#000000 guifg=#555555")
      vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#000000", fg = "#ffffff" })
    end,
  },
}
