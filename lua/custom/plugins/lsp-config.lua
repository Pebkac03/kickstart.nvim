vim.pack.add { 'https://github.com/j-hui/fidget.nvim' }
require('fidget').setup {}
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', {
    clear = true,
  }),
  callback = function(event)
    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, {
        buffer = event.buf,
        desc = 'LSP: ' .. desc,
      })
    end

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.

    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', {
        clear = false,
      })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', {
          clear = true,
        }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'kickstart-lsp-highlight',
            buffer = event2.buf,
          }
        end,
      })
    end
    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map(
        '<leader>th',
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {
            bufnr = event.buf,
          })
        end,
        '[T]oggle Inlay [H]ints'
      )
    end
  end,
})
---@type table<string, vim.lsp.Config>
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyrefly = {},
  terraformls = {},
  tombi = {},
  marksman = {},
  prettier = {},
  pyright = {},
  jsonls = { settings = { json = { schemas = require('schemastore').json.schemas(), validate = { enable = true } } } },
  -- rust_analyzer = {},
  -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
  --
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  -- ts_ls = {filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' } },
  tsc = {
    settings = {
      tsc = {
        globalPlugins = {
          name = '@vue/typescript-plugin',
          location = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node-modules/@vue/language-server',
          languages = { 'vue' },
          configNamespace = 'typescript',
        },
      },
    },
  },
  -- vtsls = {
  --   settings = {
  --     vtsls = {
  --       tsserver = {
  --         globalPlugins = {
  --           {
  --             name = '@vue/typescript-plugin',
  --             location = vim.fn.stdpath 'data' .. '/mason/packages/vue-language-server/node-modules/@vue/language-server',
  --             languages = { 'vue' },
  --             configNamespace = 'typescript',
  --           },
  --         },
  --       },
  --     },
  --   },
  --   filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  --   on_attach = function(client)
  --     local existing_capabilities = client.server_capabilities
  --     if vim.bo.filetype == 'vue' then
  --       existing_capabilities.semanticTokensProvider.full = false
  --     else
  --       existing_capabilities.semanticTokensProvider.full = true
  --     end
  --   end,
  -- },
  vue_ls = {},
  -- vtsls = {},
  --
  stylua = {},
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
          --  See https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.api.nvim_get_runtime_file('', true),
          -- library = vim.tbl_extend('force',
          -- 	vim.api.nvim_get_runtime_file('', true),
          -- 	{ '${3rd}/luv/library', '${3rd}/busted/library' }),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        schemaStore = {
          enable = false,
          url = '',
        },
        schemas = require('schemastore').yaml.schemas(),
      },
    },
  },
}
vim.pack.add {
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim',
}
-- Automatically install LSPs and related tools to stdpath for Neovim
require('mason').setup {}

-- Ensure the servers and tools above are installed
--
-- To check the current status of installed tools and/or manually install
-- other tools, you can run
--    :Mason
--
-- You can press `g?` for help in this menu.
local ensure_installed = vim.tbl_keys(servers or {})

vim.list_extend(ensure_installed, {
  'isort', -- Used to sort python imports
  'black', -- Used to format python code
})

require('mason-tool-installer').setup {
  ensure_installed = ensure_installed,
}
for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- NOTE: Configure manual capability overrides here.
local extra_capabilities = { capabilities = { textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } } } }
for name, server in pairs(servers) do
  vim.lsp.config(name, vim.tbl_deep_extend('force', server, extra_capabilities))
  vim.lsp.enable(name)
end

-- NOTE: Enable off-by-default features here.

-- vim.lsp.on_type_formatting.enable(true)

-- -- Diagnostic Config
-- -- See :help vim.diagnostic.Opts
-- vim.diagnostic.config {
-- 	severity_sort = true,
-- 	float = {
-- 		border = 'rounded',
-- 		source = 'if_many',
-- 	},
-- 	underline = {
-- 		severity = vim.diagnostic.severity.ERROR,
-- 	},
-- 	signs = vim.g.have_nerd_font and {
-- 		text = {
-- 			[vim.diagnostic.severity.ERROR] = '󰅚 ',
-- 			[vim.diagnostic.severity.WARN] = '󰀪 ',
-- 			[vim.diagnostic.severity.INFO] = '󰋽 ',
-- 			[vim.diagnostic.severity.HINT] = '󰌶 ',
-- 		},
-- 	} or {},
-- 	virtual_text = {
-- 		source = 'if_many',
-- 		spacing = 2,
-- 		format = function(diagnostic)
-- 			local diagnostic_message = {
-- 				[vim.diagnostic.severity.ERROR] = diagnostic.message,
-- 				[vim.diagnostic.severity.WARN] = diagnostic.message,
-- 				[vim.diagnostic.severity.INFO] = diagnostic.message,
-- 				[vim.diagnostic.severity.HINT] = diagnostic.message,
-- 			}
-- 			return diagnostic_message[diagnostic.severity]
-- 		end,
-- 	},
-- }
--
