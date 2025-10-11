return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer" },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        completion = { completeopt = "menu,menuone" },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        }),
        sources = {
          { name = "nvim_lsp", priority = 1000 },
          { name = "buffer",   keyword_length = 3 },
        },
        experimental = { ghost_text = true },
      })
    end,
  },
}
