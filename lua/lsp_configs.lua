-- LSP CONFIGURATION
-- Basic keymaps
local map = vim.keymap.set
map("n", "K", vim.lsp.buf.hover)
map("n", "gd", vim.lsp.buf.definition)
-- async for slow ref chasing
map("n", "gr", function()
  vim.lsp.buf_request(0, "textDocument/references", vim.lsp.util.make_position_params(), function(_, result)
    if not result or vim.tbl_isempty(result) then
      vim.notify("No references found")
      return
    end
    vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(result))
    vim.cmd("copen")
  end)
end, { desc = "Async LSP references" })
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
vim.lsp.enable("pyright")

-- rust_analyzer
vim.lsp.config("rust_analyzer", {
  -- binary which comes which toolchains
  cmd = { "/home/ross/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin/rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
  flags = { debounce_text_changes = 150 },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = false,
        runBuildScripts = false,
      },
      diagnostics = { enable = true },
      check = {
        command = "clippy",
        allTargets = true,
      },
      files = {
        excludeDirs = {
          "target",
          "examples",
          "benches",
          "tests",
        },
      },
      workspace = {
        workspaceFolders = { vim.fn.getcwd() },
      },
    },
  },
  capabilities = capabilities,
})
vim.lsp.enable("rust_analyzer")

-- this must run after Neovim's built-in LSP is loaded
vim.lsp.config("tsserver", { -- name: must be a plain string
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_markers = { "tsconfig.json", "package.json", ".git" },
  settings = {
    typescript = { suggest = { autoImports = true } },
    javascript = { suggest = { autoImports = true } },
  },
  capabilities = capabilities
})

-- start or attach to a tsserver instance for the current buffer
vim.lsp.enable("tsserver")

-- Simpler servers
for _, lsp in ipairs({ "html", "cssls", "jsonls" }) do
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
