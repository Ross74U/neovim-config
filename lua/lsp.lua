vim.lsp.enable('pyright')
vim.lsp.enable('rust_analyzer')

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
