-- nice themes
-- "blazkowolf/gruber-darker.nvim",
-- "stefanvanburen/rams.vim"
-- "fxn/vim-monochrome"
return {
  "stefanvanburen/rams.vim",
  config = function()
    vim.cmd.colorscheme("rams")
    vim.cmd("highlight StatusLine guibg=#000000 guifg=#aaaaaa")
    vim.cmd("highlight StatusLineNC guibg=#000000 guifg=#555555")
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#000000", fg = "#ffffff" })

    vim.api.nvim_set_hl(0, "@markup.raw.block.markdown", {
      bg = "#474747", -- slightly lighter gray background
      fg = "#ffffff", -- readable text foreground
    })

    vim.api.nvim_set_hl(0, "@markup.raw.markdown_inline", {
      bg = "#474747",
      fg = "#ffffff",
    })
  end,
}
