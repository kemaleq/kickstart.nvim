return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup {
        PATH = 'prepend',
      }
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'bashls',
          'cssls',
          'dockerls',
          'html',
          'jsonls',
          'lua_ls',
          'tsserver',
          'vimls',
          'yamlls',
          'marksman',
          'omnisharp',
          'tailwindcss',
        },
      }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'folke/neodev.nvim',
        opts = {},
      },
      { 'Hoffs/omnisharp-extended-lsp.nvim' },
    },

    config = function()
      require('lspconfig').bashls.setup {}
      require('lspconfig').cssls.setup {}
      require('lspconfig').dockerls.setup {}
      require('lspconfig').html.setup {}
      require('lspconfig').jsonls.setup {}
      require('lspconfig').tailwindcss.setup {}
      require('lspconfig').lua_ls.setup {
        settings = {
          Lua = {
            completion = { callSnippet = 'Replace' },
          },
        },
      }
      require('lspconfig').tsserver.setup {}
      require('lspconfig').vimls.setup {}
      require('lspconfig').yamlls.setup {}
      require('lspconfig').marksman.setup {}
      require('lspconfig').omnisharp.setup {
        cmd = { 'dotnet', vim.fn.stdpath 'data' .. '/mason/packages/omnisharp/libexec/OmniSharp.dll' },
        enable_import_completion = true,
        organize_imports_on_format = true,
        enable_roslyn_analyzers = true,
        root_dir = function()
          return vim.loop.cwd() -- current working directory
        end,
        handlers = {
          ['textDocument/definition'] = require('omnisharp_extended').definition_handler,
          ['textDocument/typeDefinition'] = require('omnisharp_extended').type_definition_handler,
          ['textDocument/references'] = require('omnisharp_extended').references_handler,
          ['textDocument/implementation'] = require('omnisharp_extended').implementation_handler,
        },
      }
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gu', require('telescope.builtin').lsp_references, '[G]oto [U]sages')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
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
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              ---@diagnostic disable-next-line: missing-parameter
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })
    end,
  },
}
