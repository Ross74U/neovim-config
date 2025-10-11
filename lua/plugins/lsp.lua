-- lua/plugins/lsp.lua
--
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
      -- ensure core tools are installed
      for _, tool in ipairs({
        "lua-language-server",
        "pyright",
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "rust-analyzer",
      }) do
        local p = require("mason-registry").get_package(tool)
        if not p:is_installed() then p:install() end
      end
    end,
  },
}
