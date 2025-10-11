-- Entry point for Neovim configuration
--
-- Bootstrap lazy.nvim package manager
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

require("options")
require("lazy").setup("lazy_plugins")
require("mappings")
require("lsp_configs")

-- /hotbuffers.lua
require("hotbuffers.init").setup({ "1", "2", "3", "8", "9", "0" })
