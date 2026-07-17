{ pkgs, lib, ... }:
{
  programs.neovim = {
    enable = true;

    # set vi alias
    viAlias = true;

    # set vim alias
    vimAlias = true;

    # extra things to make things work
    extraPackages = [
      pkgs.ripgrep
      # Nasty fucking hack to make clangd work at work
      (lib.hiPrio (
        pkgs.writeShellScriptBin "clangd" ''
          args=()
          if [ -n "''${CLANGD_QUERY_DRIVER-}" ]; then
            args+=("--query-driver=''${CLANGD_QUERY_DRIVER}")
          fi
          exec ${pkgs.llvmPackages_21.clang-unwrapped}/bin/clangd "''${args[@]}" "$@"
        ''
      ))
      pkgs.llvmPackages_21.clang-tools
      pkgs.nixfmt
      pkgs.nixd
      pkgs.tinymist
      pkgs.typstyle
      pkgs.idris2
      pkgs.idris2Packages.idris2Lsp
      pkgs.ty
      pkgs.ruff
      pkgs.gh
    ];

    # plugins
    plugins = [
      # colorscheme
      pkgs.vimPlugins.aurora

      # navigation
      pkgs.vimPlugins.telescope-nvim

      # git
      pkgs.vimPlugins.gitsigns-nvim

      # lsp stuff
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.nvim-cmp
      pkgs.vimPlugins.luasnip
      pkgs.vimPlugins.cmp-buffer
      pkgs.vimPlugins.cmp-path
      pkgs.vimPlugins.cmp-nvim-lsp

      # typst note-taking
      pkgs.vimPlugins.typst-preview-nvim

      # basic
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.indent-blankline-nvim

      # async helper
      pkgs.vimPlugins.plenary-nvim
      pkgs.vimPlugins.nvim-web-devicons
    ];

    # extra lua
    extraLuaConfig = ''
      -- color
      vim.g.aurora_transparent = 1
      vim.cmd.colorscheme('aurora')

      -- defaults
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 4
      vim.opt.tabstop = 4
      vim.opt.smarttab = true
      vim.opt.autoindent = true
      vim.opt.smartindent = true
      vim.opt.cindent = true
      vim.opt.number = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"

      -- diagnostics
      vim.opt.updatetime = 300
      vim.diagnostic.config{
        virtual_text = false,
        virtual_lines = { current_line = true },
        signs        = true,
        underline    = true,
        severity_sort = true,
        float = { border = 'rounded', source = true },
      }
      -- clangd: switch between source and header (clangd protocol extension)
      local function switch_source_header()
        local client = vim.lsp.get_clients({ bufnr = 0, name = 'clangd' })[1]
        if not client then
          return vim.notify('clangd not attached', vim.log.levels.WARN)
        end
        client:request('textDocument/switchSourceHeader',
          vim.lsp.util.make_text_document_params(0),
          function(err, result)
            if err then return vim.notify(tostring(err), vim.log.levels.ERROR) end
            if not result then
              return vim.notify('no corresponding file', vim.log.levels.WARN)
            end
            vim.cmd.edit(vim.uri_to_fname(result))
          end, 0)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local buf = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local tb = require('telescope.builtin')

          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          -- navigation (telescope pickers beat the quickfix list)
          map('n', 'gd',  tb.lsp_definitions,       'Goto definition')
          map('n', 'grr', tb.lsp_references,        'References')
          map('n', 'gri', tb.lsp_implementations,   'Implementations')
          map('n', 'grt', tb.lsp_type_definitions,  'Type definition')
          map('n', 'gO',  tb.lsp_document_symbols,  'Document symbols')
          map('n', '<leader>fs', tb.lsp_dynamic_workspace_symbols, 'Workspace symbols')
          map('n', '<leader>fd', function()
            tb.diagnostics{ severity_bound = vim.diagnostic.severity.WARN }
          end, 'Workspace diagnostics')

          -- hierarchies
          map('n', '<leader>ci', vim.lsp.buf.incoming_calls, 'Incoming calls')
          map('n', '<leader>co', vim.lsp.buf.outgoing_calls, 'Outgoing calls')
          map('n', '<leader>cs', function() vim.lsp.buf.typehierarchy('subtypes') end,   'Subtypes')
          map('n', '<leader>cp', function() vim.lsp.buf.typehierarchy('supertypes') end, 'Supertypes')

          -- clangd extras
          map('n', '<leader>o', switch_source_header, 'Switch source/header')

          -- inlay hints (toggle: always-on is noise)
          map('n', '<leader>ih', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled{ bufnr = buf }, { bufnr = buf })
          end, 'Toggle inlay hints')

          -- diagnostics
          map('n', ']e', function()
            vim.diagnostic.jump{ count = 1, severity = vim.diagnostic.severity.ERROR }
          end, 'Next error')
          map('n', '[e', function()
            vim.diagnostic.jump{ count = -1, severity = vim.diagnostic.severity.ERROR }
          end, 'Prev error')

          -- format
          map({ 'n', 'v' }, '<leader>fm', function() vim.lsp.buf.format{ async = true } end, 'Format')

          -- highlight other uses of the symbol under the cursor
          if client and client:supports_method('textDocument/documentHighlight') then
            local grp = vim.api.nvim_create_augroup('lsp_hl_' .. buf, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = grp, buffer = buf, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group = grp, buffer = buf, callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })


      -- leader
      vim.g.mapleader = " "

      -- scroll
      vim.opt.mousescroll = "ver:1,hor:1"

      -- color column
      vim.opt.colorcolumn = "120"
      vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#ff5874" })

      -- telescope
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

      -- lsp
      vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
      vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
      vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
      vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
      vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
      vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
      vim.keymap.set('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format()<CR>')

      -- journal
      vim.keymap.set("n", "<leader>d", function()
        local today = os.date("%Y-%m-%d")
        local journal_path = vim.fn.expand("~/scratch/daily/" .. today .. ".md")

        vim.cmd("edit " .. journal_path)

        if vim.fn.line('$') == 1 and vim.fn.getline(1) == "" then
          local title = "# " .. today
          local initial_content = { title, "" } 
          vim.api.nvim_buf_set_lines(0, 0, -1, false, initial_content)
          vim.api.nvim_win_set_cursor(0, { 2, 0 })
        end
      end, { desc = "Open daily journal 📔" })

      -- yank
      vim.keymap.set({'n', 'v'}, 'y', '"+y', { desc = 'Yank to system clipboard' })
      vim.keymap.set({'n'}, 'Y', '"+Y', { desc = 'Yank line to system clipboard' })

      -- terminal
      function Terminal()
          vim.cmd("botright split")
          vim.cmd("resize 10")
          vim.cmd("term")
          vim.cmd("startinsert")
      end
      vim.api.nvim_set_keymap('n', '<leader>t', ':lua Terminal()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
      vim.api.nvim_create_autocmd("TermOpen", {
          pattern = "*",
          callback = function()
              vim.cmd("startinsert")  -- Automatically enter insert mode
          end
      })

      -- completion
      vim.opt.completeopt = { 'menuone', 'noselect' }
      local cmp = require('cmp')
      cmp.setup{
        snippet = { expand = function(a) require('luasnip').lsp_expand(a.body) end },
        sources  = { { name = 'nvim_lsp' }, { name = 'path' }, { name = 'buffer' } },
        mapping = cmp.mapping.preset.insert({
          ['<C-j>'] = cmp.mapping.select_next_item(),  -- like <C-n> but feels vim-ish
          ['<C-k>'] = cmp.mapping.select_prev_item(),  -- like <C-p>
          ['<C-f>'] = cmp.mapping.scroll_docs(4),      -- page down docs
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),     -- page up
          ['<C-CR>']  = cmp.mapping.confirm({ select = true }),
          ['<C-e>'] = cmp.mapping.abort(),
        }),
      }
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- indent lines (indent-blankline)
      require("ibl").setup {
        indent = { 
          char = "│", -- Uses a smooth continuous vertical line
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
        },
      }

      -- extract util
      local util = require("lspconfig.util")

      -- nix lsp
      vim.lsp.config('nixd', {
        capabilities = capabilities,
        settings = {
          nixd = {
            formatting = { command = { 'nixfmt' } },
          },
        },
      })
      vim.lsp.enable('nixd', true)

      -- zig lsp
      vim.lsp.config.zls = {
        capabilities = capabilities,
      }
      vim.lsp.enable('zls', true)

      -- idris2 lsp
      vim.lsp.config('idris2_lsp', {
        capabilities = capabilities,
      })
      vim.lsp.enable('idris2_lsp', true)

      -- rust-analyzer
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
      })
      vim.lsp.enable('rust_analyzer', true)

      -- python
      vim.lsp.config('ty', {
        capabilities = capabilities,
      })
      vim.lsp.enable('ty', true)
      vim.lsp.config('ruff', {
        capabilities = capabilities,
      })
      vim.lsp.enable('ruff', true)

      --- clangd
      vim.lsp.config.clangd = {
        cmd = {
          'clangd',
          '--clang-tidy',
          '--background-index',
          '--background-index-priority=normal',
          '--offset-encoding=utf-8',
          '--completion-style=detailed',
          '--header-insertion=never',
          '--all-scopes-completion',
          '--pch-storage=memory',
          '--limit-references=2000',
          '--limit-results=200',
          '-j=8',
        },
        capabilities = capabilities,
        root_markers = { '.clangd', 'compile_commands.json' },
        filetypes = { 'c', 'cpp' },
      }
      vim.lsp.enable('clangd', true)

      -- typst lsp
      vim.lsp.config('tinymist', {
        settings = { formatterMode = "typstyle" },
      })

      -- gitsigns (git integration & blame)
      require('gitsigns').setup {
        -- Enable inline virtual text blame by default
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- places blame at the end of the line
          delay = 500,           -- half-second delay before showing blame
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Keymaps for Git Blame
          map('n', '<leader>gb', function() gs.blame_line{full=true} end, { desc = 'Git Blame floating window' })
          map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle inline Git Blame' })
          
          -- Navigation for git hunks (optional but handy)
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = 'Next Git hunk'})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true, desc = 'Previous Git hunk'})
        end
      }

      -- localleader defaults to \, which is miserable to type
      vim.g.maplocalleader = ","
    '';
  };
}
