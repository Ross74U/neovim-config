-- nice themes
-- "blazkowolf/gruber-darker.nvim",
-- "stefanvanburen/rams.vim"
-- "fxn/vim-monochrome"
-- return {
-- "stefanvanburen/rams.vim",
--  config = function()
--  end,
--}

-- vim.cmd.colorscheme("rams")
vim.cmd("highlight StatusLine guibg=#000000 guifg=#aaaaaa")
vim.cmd("highlight StatusLineNC guibg=#000000 guifg=#555555")
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#000000", fg = "#ffffff" })

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2f4260" })

vim.api.nvim_set_hl(0, 'Keyword', { bold = false, fg = "#f4de9a" })
vim.api.nvim_set_hl(0, 'Statement', { bold = false })
vim.api.nvim_set_hl(0, 'Identifier', { bold = false })
vim.api.nvim_set_hl(0, 'Function', { bold = false })
vim.api.nvim_set_hl(0, 'Comment', { fg = "#747474", bold = false, italic = true })

return {}
