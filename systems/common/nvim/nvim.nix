{ pkgs, ... }: {
  programs.neovim = {
    enable = true;

    # set vi alias
    viAlias = true;

    # set vim alias
    vimAlias = true;

    # extra things to make things work
    extraPackages = [
      pkgs.ripgrep
      pkgs.llvmPackages_21.clang-tools
      pkgs.nixfmt-classic
      pkgs.nixd
      pkgs.tinymist
      pkgs.typstyle
    ];

    # plugins
    plugins = [
      # colorscheme
      pkgs.vimPlugins.aurora

      # navigation
      pkgs.vimPlugins.telescope-nvim

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

      # async helper
      pkgs.vimPlugins.plenary-nvim
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
      vim.diagnostic.config{
        virtual_text = true,
        signs        = true,
        underline    = true,
      }

      -- leader
      vim.g.mapleader = " "

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

      -- zig lsp
      vim.lsp.config.zls = {
        capabilities = capabilities,
      }
      vim.lsp.enable('zls', true)

      -- rust-analyzer
      vim.lsp.config('rust_analyzer', {
        capabilities = capabilities,
      })

      --- clangd
      vim.lsp.config.clangd = {
        cmd = {
          'clangd',
          '--clang-tidy',
          '--background-index',
          '--offset-encoding=utf-8',
        },
        root_markers = { '.clangd', 'compile_commands.json' },
        filetypes = { 'c', 'cpp' },
      }
      vim.lsp.enable('clangd', true)

      -- typst lsp
      vim.lsp.config('tinymist', {
        settings = { formatterMode = "typstyle" },
      })
    '';
  };
}
