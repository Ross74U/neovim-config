-- LSP CONFIGURATION
-- Basic keymaps
local map = vim.keymap.set
map("n", "K", vim.lsp.buf.hover)
map("n", "gd", vim.lsp.buf.definition)
map("n", "gr", vim.lsp.buf.references)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>ca", vim.lsp.buf.code_action)

-- Capabilities (if using nvim-cmp)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Lua LS
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
    },
  },
  capabilities = capabilities,
})

vim.lsp.enable("lua_ls")

-- Register the pyright config
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- Enable pyright for matching buffers
vim.lsp.enable("pyright")

-- rust_analyzer
vim.lsp.config("rust_analyzer", {
  -- binary which comes which toolchains
  cmd = { "/home/ross/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      check = {
        command = "clippy", -- ✅ new form
        allTargets = true,
      },
      diagnostics = { enable = true },
    },
  },
  capabilities = capabilities,
})

-- Enable the server for matching buffers automatically
vim.lsp.enable("rust_analyzer")

-- Simpler servers
for _, lsp in ipairs({ "tsserver", "html", "cssls", "jsonls" }) do
  vim.lsp.config(lsp, { capabilities = capabilities })
end

-- Enable everything else
vim.lsp.enable({ "lua_ls", "pyright", "tsserver", "html", "cssls", "jsonls", "rust_analyzer" })

-- Optional: format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function() vim.lsp.buf.format({ async = false }) end,
})

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "References" })

-- Borders for LSP popups
vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
