{ pkgs, user, stateVersion, ... }: {
  # with home manager, we configure user only packages and dotfiles
  home = {
    # the user for our system
    username = user;

    # propegate nixos base version
    stateVersion = stateVersion;

    # packages for the user
    packages = [
      # formatters
      pkgs.nixfmt-classic

      # helpers
      pkgs.htop
      pkgs.rsync
      pkgs.jq

      # for hyprland
      pkgs.wofi
      pkgs.hyprshot
      pkgs.bibata-cursors

      # font for everything
      pkgs.nerd-fonts.fantasque-sans-mono

    ];

    # set variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "nvim +Man!";
    };
  };

  # git settings
  programs.git = {
    enable = true;
    userName = "Niels";
    userEmail = "hidden@email.com";
  };

  # bash settings
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      PS1="\[\e[1;32m\]\u\[\e[0m\]@\[\e[1;31m\]$HOSTNAME\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "
    '';
  };

  # neovim settings
  programs.neovim = {
    enable = true;

    # set vi alias
    viAlias = true;

    # set vim alias
    vimAlias = true;

    # extra things to make things work
    extraPackages =
      [ pkgs.ripgrep pkgs.nixfmt-classic pkgs.clang-tools pkgs.nixd ];

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

      # basic
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars

      # async helper
      pkgs.vimPlugins.plenary-nvim
    ];

    # extra lua
    extraLuaConfig = ''
      -- color
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

      -- nix lsp
      require('lspconfig').nixd.setup{
        capabilities = capabilities,
        settings = {
          nixd = {
            formatting = { command = { 'nixfmt' } },
          },
        },
      }

      -- nix lsp
      require('lspconfig').clangd.setup{
        capabilities = capabilities,
        root_dir = function(fname)
          local util = require('lspconfig.util')
          return util.root_pattern('compile_commands.json')(fname)
              or util.find_git_ancestor(fname)
              or util.path.dirname(fname)
        end,
        cmd = { 'clangd', '--background-index' },
      }

    '';
  };

  # firefox settings
  programs.firefox.enable = true;

  # hyprland settings
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

      # on start
      exec-once = [ "hyprctl setcursor Bibata-Modern-Ice 16" "waybar &" ];

      # default programs
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";

      # set super + looks
      general = {
        "$mainMod" = "$mod";
        layout = "dwindle";
        gaps_in = 8;
        gaps_out = 8;
        border_size = 3;
      };

      # no rounding
      decoration = { rounding = 0; };

      # disable anime girl
      misc = {
        "force_default_wallpaper" = 0;
        "disable_hyprland_logo" = "true";
      };

      # bindings for hyprland
      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, exec, killactive"
        "$mainMod, M, exec, exit"
        "$mainMod, R, exec, $menu"
        "$mainMod, S, exec, togglesplit"
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
      ];
    };

    extraConfig = ''
      monitor=eDP-1,preferred,auto,1.0
      monitor=,preferred,auto,1.0,mirror,eDP-1
    '';
  };

  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-right = [ "network" "cpu" "memory" "battery" "clock" ];
        tray = { spacing = 10; };
        network = { format = "{essid} {ipaddr}"; };
        cpu = { format = "CPU: {usage}%"; };
        memory = { format = "MEM: {}%"; };
        battery = { format = "BAT: {capacity}%"; };
        clock = { format = "{:%I:%M}"; };
      };
    };

    style = ''
      * { 
        font-family: "FantasqueSansM Nerd Font"; 
        font-weight: bold;
        border: none;
        border-radius: 4px;
        font-size: 18px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0.9);
        color: #ffffff;
      }

      #workspaces button {
        box-shadow: inset 0 -3px transparent;
        color: #ffffff;
      }

      #workspaces button.active {
        background-color: #64727D;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #tray {
        padding: 0px 10px;
        margin: 6px 3px;
        color: #ffffff;
      }
    '';
  };

  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    font.name = "FantasqueSansM Nerd Font";
    font.size = 10;
  };
}
