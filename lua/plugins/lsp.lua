-- LSP configuration
return {
  -- Mason LSP installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
      -- Ensure these tools are installed
      local ensure_installed = {
        "lua-language-server",
        "pyright",
        "clangd",
        "typescript-language-server",
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "rust-analyzer",
        "codelldb",
      }

      local mr = require("mason-registry")
      for _, tool in ipairs(ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },

  -- Mason-lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "clangd",
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "rust_analyzer",
        },
        automatic_installation = true,
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "simrat39/rust-tools.nvim",
    },
    config = function()
      -- LSP keybindings
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover information" })
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "Go to implementation" })
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { desc = "Signature help" })
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename symbol" })
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code actions" })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = "Find references" })

      -- Get capabilities from cmp_nvim_lsp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Setup basic LSP servers
      require("lspconfig").lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      require("lspconfig").pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      -- Setup other standard LSP servers
      local servers = { "clangd", "ts_ls", "html", "cssls", "jsonls" }
      for _, lsp in ipairs(servers) do
        require("lspconfig")[lsp].setup({
          capabilities = capabilities,
        })
      end

      -- Special setup for Rust with rust-tools
      require("rust-tools").setup({
        tools = {
          hover_actions = { auto_focus = true },
          inlay_hints = {
            auto = false,
            show_parameter_hints = false,
            only_current_line = false,
            -- force-clear any virtual text
            enabled = false,
          },
        },
        server = {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            -- Enable inlay hints
            -- if client.server_capabilities.inlayHintProvider then
            --  vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            --end

            -- Make sure formatting is enabled
            client.server_capabilities.documentFormattingProvider = true

            -- Add format on save specifically for Rust files
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr, async = false })
              end,
            })

            -- Rust specific keybindings
            vim.keymap.set("n", "<leader>rr", require("rust-tools").runnables.runnables,
              { buffer = bufnr, desc = "Rust Runnables" })
            vim.keymap.set("n", "<leader>rd", require("rust-tools").debuggables.debuggables,
              { buffer = bufnr, desc = "Rust Debuggables" })
            vim.keymap.set("n", "<leader>re", require("rust-tools").expand_macro.expand_macro,
              { buffer = bufnr, desc = "Expand Macro" })
          end,
          settings = {
            ["rust-analyzer"] = {
              imports = {
                granularity = {
                  group = "module",
                },
                prefix = "self",
              },
              cargo = {
                buildScripts = {
                  enable = true,
                },
                features = "all",
              },
              procMacro = {
                enable = true
              },
              checkOnSave = {
                command = "clippy",
                allFeatures = true,
                extraArgs = { "--", "-W", "clippy::all" },
              },
              diagnostics = {
                enable = true,
              },
              check = {
                command = "clippy",
                features = "all",
              },
              assist = {
                importGranularity = "module",
                importPrefix = "self",
              },
              inlayHints = {
                enable = false,
                lifetimeElisionHints = {
                  enable = "never",
                },
                reborrowHints = {
                  enable = "never",
                },
              },
            }
          },
        },
      })
    end,
  },

  -- null-ls for formatting
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      -- Simple setup with just the most reliable formatters
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.prettier,
        },
      })

      -- Format on save for non-Rust files
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.lua", "*.js", "*.ts", "*.jsx", "*.tsx", "*.json", "*.html", "*.css" },
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,
  },
}
