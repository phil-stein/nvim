
-- config based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
-- windows: `git clone https://github.com/phil-stein/nvim %AppData%../local/nvim`

-- [[ useful characters, chars, icons, deviocons ]]
-- '', '', '', '' -> seperators
-- '', '', '', '' -> seperators
-- ─│─│╭╮╯╰           -> rounded window corners
-- ─│─│┌┐┘└           -> window corners
-- ✗, ➜, ✓, ◍         -> useful random nerdfont chars
-- "", "", "" "", "", "", "", "", "", "", "", "" -> dapui chars
-- '🛑', "", "", "",
--  "✹", "✚", "✭", "➜", "═", "✖", "✗", "✔", '☒',
-- :NvimWebDeviconsHiTest -> shows all registered icons

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- tabs as spaces
vim.o.tabstop     = 2     -- A TAB character looks like 4 spaces
vim.o.expandtab   = true  -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 2     -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth  = 2     -- Number of spaces inserted when indenting
vim.o.scrolloff   = 8     -- offset from bottom/top when scrolling

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ keymaps | mappings ]]
  -- resize window with - _ , ;
  vim.keymap.set('n', '-', ':vertical resize +10<CR>')
  vim.keymap.set('n', '_', ':vertical resize -10<CR>')
  vim.keymap.set('n', ',', ':resize +4<CR>')
  vim.keymap.set('n', ';', ':resize -4<CR>')
  -- remap q: to not show command history, as thats annoying
  -- exiting with q and then : to start command opens this
  vim.keymap.set('',  'q:', '')
  vim.keymap.set('i', 'q:', '')
  vim.keymap.set('n', 'q:', '')
  vim.keymap.set('v', 'q:', '')
  vim.keymap.set('x', 'q:', '')
  vim.keymap.set('t', 'q:', '')

-- [[ custom commands ]]
vim.api.nvim_create_user_command('W',  function() vim.cmd('wall') require('fidget').notify(':W -> saved all') end,        {  desc = ':W -> :wall'})
vim.api.nvim_create_user_command('WQ', function() vim.cmd('wall | qall') end, {  desc = ':WQ -> :wall | :qall'})

vim.api.nvim_create_user_command('Hex',   function() vim.cmd('%!xxd | set ft=xxd') require('fidget').notify(':Hex -> conv to hex')  end, {  desc = ':Hex -> %!xxd turns text to hex representation, activates syntax highlighting'})
vim.api.nvim_create_user_command('Unhex', function() vim.cmd('%!xxd -r') require('fidget').notify(':Unhex -> conv to text')         end, {  desc = ':Unhex -> %!xxd -r turns hex representation to text'})

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- devicons
    'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup()
    end
  },

  {
    -- glsl highlighting
    'tikhomirov/vim-glsl',
  },

  -- [[ Configure nvim-cmp ]]
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function() end)(),
        dependencies = { },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          -- ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<S-Tab>']= cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  -- { -- auto-session / session-management
  --   'rmagatti/auto-session',
  --   config = function()
  --     require("auto-session").setup {
  --       log_level = "error",
  --       cwd_change_handling = {
  --         restore_upcoming_session = true, -- already the default, no need to specify like this, only here as an example
  --         pre_cwd_changed_hook = nil, -- already the default, no need to specify like this, only here as an example
  --         post_cwd_changed_hook = function() -- example refreshing the lualine status line _after_ the cwd changes
  --           require("lualine").refresh() -- refresh lualine so the new session name is displayed in the status bar
  --         end,
  --       },
  --     }
  --   end,
  -- },
  {
    'rmagatti/auto-session',
    lazy = false,
    keys = {
      -- Will use Telescope if installed or a vim.ui.select picker otherwise
      { '<leader>S', '<cmd>SessionSearch<CR>', desc = 'Session search' },
    },
    opts = {
      -- ⚠️ This will only work if Telescope.nvim is installed
      -- The following are already the default values, no need to provide them if these are already the settings you want.
      session_lens = {
        -- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
        load_on_setup = true,
        previewer = false,
        mappings = {
          -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
          delete_session = { "i", "<C-D>" },
          alternate_session = { "i", "<C-S>" },
          copy_session = { "i", "<C-Y>" },
        },
        -- Can also set some Telescope picker options
        -- For all options, see: https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L112
        theme_conf = {
          border = true,
          layout_config = {
            width = 0.8, -- Can set width and height as percent of window
            height = 0.8,
          },
        },
      },
    }
  },

  {
    -- floating command line
    'VonHeikemen/fine-cmdline.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    -- open with :
    vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', {noremap = true}),
    -- vim.api.nvim_set_keymap('v', '<CR>', "<C-u>FineCmdline '<,'><CR>", {noremap = true}),
    --  open with enter
    -- vim.api.nvim_set_keymap('n', '<CR>', '<cmd>FineCmdline<CR>', {noremap=true}),
    config = function()
      require('fine-cmdline').setup({
        cmdline = {
          enable_keymaps = true,
          smart_history = true,
          prompt = '>'
        },
        popup = {
          position = {
            row = '50%',  -- '10%'
            col = '50%',
          },
          size = {
            width = '60%',
          },
          border = {
            style = 'rounded',
          },
          win_options = {
            -- winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',  -- highlight border
            winhighlight = 'Normal:Normal,FloatBorder:Normal',  -- dont highlight border
          },
        },
        hooks = {
          -- before_mount = function(input)
          --   -- code
          -- end,
          after_mount = function(input)
            -- make escape go to normal mode
            vim.keymap.set('i', '<Esc>', '<cmd>stopinsert<cr>', {buffer = input.bufnr})
          end,
          -- set_keymaps = function(imap, feedkeys)
          --   -- code
          -- end
        }
      })
    end,
  },

  { -- bufferline / tabline
    'akinsho/bufferline.nvim',
    after = "catppuccin",
    config = function()
      require("bufferline").setup {
        highlights = require("catppuccin.groups.integrations.bufferline").get(),
        options = {
          separator_style = 'slant',
          mode = 'tabs',
          themable = true,
          close_command = "q",
          right_mouse_command = "q",
          enforce_regular_tabs = true,
          -- sort_by = 'insert_after_current', -- 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
              local icon = level:match("error") and " " or ""
              return " " .. icon .. count
          end
        },
      }
    end
  },
  {
    -- telescope tabs | tab
  	'LukasPietzschmann/telescope-tabs',
  	config = function()
  		require('telescope').load_extension 'telescope-tabs'
  		require('telescope-tabs').setup {
        -- setting keybinds to garbage so its effectively deactivated
        close_tab_shortcut_i = '<leader><C-ü>B', -- if you're in insert mode
        close_tab_shortcut_n = '<leader><C-ü>B', -- if you're in normal mode
  		}
  	end,
  	dependencies = { 'nvim-telescope/telescope.nvim' },
  },

  { -- floating terminal, toggle term
    'akinsho/toggleterm.nvim', version = "*", opts = {},
    config = function()
      require("toggleterm").setup {
        -- size can be a number or function which is passed the current terminal
        -- size = 20,
        -- size = function(term)
        --   if term.direction == "horizontal" then
        --     return 15
        --   elseif term.direction == "vertical" then
        --     return vim.o.columns * 0.4
        --   end
        -- end,
        name = "terminal",
        open_mapping = [[<C-t>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        start_in_insert = true,
        on_open = function() vim.cmd('startinsert') end, -- start in insert
        shade_filetypes = {},
        autochdir = true, -- when neovim changes it current directory the terminal will change it's own when next it's opened
        -- highlights = {
        --   -- highlights which map to a highlight group name and a table of it's values
        --   -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
        --   Normal = {
        --     guibg = "<VALUE-HERE>",
        --   },
        --   NormalFloat = {
        --     link = 'Normal'
        --   },
        --   FloatBorder = {
        --     guifg = "<VALUE-HERE>",
        --     guibg = "<VALUE-HERE>",
        --   },
        -- },
        shade_terminals = false, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
        -- shading_factor = '<number>', -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        persist_size = true,
        persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
        direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float',
        close_on_exit = true, -- close the terminal window when the process exits
         -- Change the default shell. Can be a string or a function returning a string
        shell = vim.o.shell,
        auto_scroll = true, -- automatically scroll to the bottom on terminal output
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
          -- The border key is *almost* the same as 'nvim_open_win'
          -- see :h nvim_open_win for details on borders however
          -- the 'curved' border is a custom border type
          -- not natively supported but implemented in this plugin.
          border = "curved", -- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
          -- like `size`, width, height, row, and col can be a number or function which is passed the current terminal
          width  = math.floor(vim.o.columns * 0.6),
          height = math.floor(vim.o.lines   * 0.8),
          -- row = <value>,
          -- col = <value>,
          -- winblend = 3,
          -- zindex = <value>,
          title_pos = 'center', -- 'left' | 'center' | 'right', position of the title of the floating window
        },
        winbar = {
          enabled = false,
          name_formatter = function(term) --  term: Terminal
            return term.name
            -- return "hello"
          end
        },
      }
    end,

    vim.keymap.set('n', '<C-b>', ':ToggleTerm<CR>build<CR>', { silent = true , desc = "call build batch/bash file"}),
  },

  { -- hover / K documentation popup
    "lewis6991/hover.nvim",
    config = function()
        -- require('hover').register() {
        --   priority = 150,
        --   name = 'doc',
        --   enabled = function(bufnr)
        --     return true
        --   end,
        --   execute = function(opts, done)
        --     -- done{lines={'TEST'}, filetype="markdown"}
        --     done{filetype="c"}
        -- end,
        -- }
        require("hover").setup {
            init = function()
                -- Require providers
                require("hover.providers.lsp")
                -- require('hover.providers.gh')
                -- require('hover.providers.gh_user')
                -- require('hover.providers.jira')
                -- require('hover.providers.man')
                -- require('hover.providers.dictionary')
                -- require('hover.providers.doc')
            end,
            preview_opts = {
                -- not how highlighting works here
                -- winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',  -- highlight border
                -- winhighlight = 'Normal:Normal,FloatBorder:Normal',  -- dont highlight border
                border = 'rounded' -- 'single'
            },
            -- Whether the contents of a currently open hover window should be moved
            -- to a :h preview-window when pressing the hover keymap.
            preview_window = false,
            title = true,
            mouse_providers = {
                'LSP'
            },
            mouse_delay = 1000
        }

        -- Setup keymaps
        vim.keymap.set("n", "K",    require("hover").hover, {desc = "hover.nvim"})
        vim.keymap.set("n", "gK",   require("hover").hover_select, {desc = "hover.nvim (select)"})
        vim.keymap.set("n", "<C-p>", function() require("hover").hover_switch("previous") end, {desc = "hover.nvim (previous source)"})
        vim.keymap.set("n", "<C-n>",  function() require("hover").hover_switch("next") end, {desc = "hover.nvim (next source)"})

        -- doesnt work
        -- -- Mouse support
        -- vim.keymap.set('n', '<MouseMove>', require('hover').hover_mouse, { desc = "hover.nvim (mouse)" })
        -- vim.o.mousemoveevent = true
    end
  },

  {
    -- vimwiki
    "vimwiki/vimwiki",
    init = function()
        vim.g.vimwiki_list = {
            {
            path = '/workspace/vim/vimwiki',
            syntax = 'default',
            ext = '.wiki',
            },
        }
    end,
  },

  { -- [[ dap ]] -> debug adapter protocol, debugging using gdb in nvim
          -- added myself, dap debugging
  --   'mfussenegger/nvim-dap',
  --   'jay-babu/mason-nvim-dap.nvim',
  -- },
  -- { -- [[ dapui ]] -> show stacktraces, watches, etc, in ui windows
  --   "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    "mfussenegger/nvim-dap",
    dependencies = {
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require('dapui').setup()
      require('nvim-dap-virtual-text').setup()
    end,

    -- [[ dap / debugging keymap ]]
    vim.keymap.set('n', '<F4>', function() require('dap').close() require('dapui').close() end,
                                                                           { desc = 'F4 -> close dap'}),
    vim.keymap.set('n', '<F5>', function() require('dap').continue()  end, { desc = 'F5 -> run debuggger'}),
    vim.keymap.set('n', '<F6>', function() require('dap').step_into() end, { desc = 'F6 -> step into'}),
    vim.keymap.set('n', '<F7>', function() require('dap').step_over() end, { desc = 'F7 -> step over'}),
    vim.keymap.set('n', '<F8>', function() require('dap').step_out()  end, { desc = 'F8 -> step out'}),

    vim.keymap.set('n', '<leader>b',  function() require('dap').toggle_breakpoint() end, { desc = 'leader b  -> toggle breakpoint'}),
    vim.keymap.set('n', '<leader>gb',  function() require('dap').run_to_cursor() end, { desc = 'leader gb  -> run debugger, break at cursor'}),
    vim.keymap.set('n', '<leader>dr', function() require('dap').repl.open()         end, { desc = 'leader dr -> open repl'}),

    vim.keymap.set('n', '<leader>d',  function() require('dapui').toggle() end, {  silent = true, desc = 'leader d  -> toggle debug ui, does this automatically'}),

    vim.keymap.set('n', '<leader>k',  function() require('dapui').eval(nil, {enter = true }) end,
      {  silent = true, desc = 'leader k  -> show info about word under cursor'}),

  },

  { -- doc | DOC, custom hotkey usinf nui.nvim
    -- :Doc command
    -- vim.api.nvim_buf_create_user_command(0, 'Doc',
    -- dependencies = { 'MunifTanjim/nui.nvim' },
    vim.api.nvim_create_user_command('Doc',
      function(opts)
        local Popup = require("nui.popup")
        local popup = Popup({
          position = "50%",
          size = {
            width  = 0.4,
            height = 0.65,
          },
          enter = true,
          focusable = true,
          zindex = 50,
          relative = "editor",
          border = {
            padding = {
              top = 2,
              bottom = 2,
              left = 3,
              right = 3,
            },
            style = "rounded",
            text = {
              top = " doc: "..opts.fargs[1].." ",
              top_align = "center",
              -- bottom = "I am bottom title",
              -- bottom_align = "left",
            },
          },
          buf_options = {
            modifiable = false,
            readonly = true,
          },
          win_options = {
            -- winblend = 10,
            -- winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
            winhighlight = "Normal:Normal,FloatBorder:Normal",
          },
        })
        -- popup:mount()
        popup:show()

        -- close popup when leaving it
        local event = require("nui.utils.autocmd").event
        popup:on({ event.BufLeave, event.BufDelete, event.BufHidden },
          function()
            popup:unmount()
          end, { once = true })
        -- quit with esc or q
        popup:map("t", "<esc>", function() vim.cmd('q!') popup:unmount() end)
        popup:map("t", "q",     function() vim.cmd('q!') popup:unmount() end)

        vim.cmd('term doc '..opts.fargs[1])
        vim.cmd('startinsert')
      end,
      {  nargs = 1, desc = ''}),
    -- end doc cmd
    vim.keymap.set('n', '<C-h>', ':Doc neovim-mappings<CR>', { silent = true, desc = "show neovim mappings"}),
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
       },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup {
        flavour = "frappe", -- latte, frappe, macchiato, mocha
        dim_inactive = {
          enabled = true, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.1, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, no_bold = false, no_underline = false,
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
            -- "italic", "bold"
            comments = { },
            conditionals = { },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
            -- miscs = {}, -- Uncomment to turn off hard-coded styles
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          treesitter = true,
          notify = false,
          mason = true,
          dap = true,
          dap_ui = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
                errors = { "bold" },
                hints = { "italic" },
                warnings = { },
                information = { },
            },
            underlines = {
                errors = { "underline" },
                hints = { "underline" },
                warnings = { "underline" },
                information = { "underline" },
            },
            inlay_hints = {
                background = true,
            },
          },
          telescope = {
            enabled = true,
            -- style = "nvchad"
            },
          vimwiki = true,
          which_key = true,
          lsp_trouble = true,
        },
      }
    vim.cmd.colorscheme("catppuccin")
    end,
    -- more custom highlighting after lazy-vim plugin stuff
  },

  { -- change line number to reflect current mode
    'mawkler/modicator.nvim',
    config = function()
      require('modicator').setup()
    end
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    dependencies = { 'rmagatti/auto-session' },
    -- See `:help lualine.txt`
    after = "catppuccin",
    opts = {
      options = {
        icons_enabled = true,
        theme = 'catppuccin', -- 'auto',
        -- component_separators = '|',
        -- section_separators = '',
        component_separators = { left = '', right = ''},
        -- section_separators = { left = '', right = ''},
        section_separators = { left = '', right = '' },
        -- component_separators = { left = '', right = '' }
      },
      sections = { -- 'filename','encoding', 'fileformat', 
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics', 'vim.fn.expand("%:.")'},
        -- lualine_c = {'require("auto-session.lib").current_session_name())' },
        lualine_c = {'string.sub( require("auto-session.lib").current_session_name(), 5)' },
        -- lualine_c = {'vim.fn.expand("%:.")', 'require("auto-session.lib").current_session_name()', 'require("nvim_lsp").status()' }, 

        lualine_x = { 'filetype' },
        lualine_y = { 'os.date("%I:%M", os.time())' },
        lualine_z = { 'progress', 'location', 'vim.api.nvim_buf_line_count(0)'}
      },
      inactive_sections = {
        lualine_a = { 'diagnostics', 'vim.fn.expand("%:.")' }, -- relative path
        lualine_b = {},
        lualine_c = {},
        lualine_x = { 'filetype', 'os.date("%I:%M", os.time())', 'location', 'vim.api.nvim_buf_line_count(0)' },
        lualine_y = {},
        lualine_z = {}
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'BurntSushi/ripgrep',
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  -- {
  --   -- [[ nerdtree | file browser ]]
  --   'preservim/nerdtree',
  --   vim.api.nvim_set_keymap("n","<C-d>", ":NERDTreeToggle<CR>", { noremap = true }),
  -- },
  {
    -- [[ neotree | file browser ]]
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies =
    {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    -- vim.api.nvim_set_keymap("n","<C-d>", ":tabnew | Neotree position=current<CR>", { noremap = true }),
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },


  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})


-- [[ custom highlights ]] 
-- doesnt work setting it in catppuccin directly

-- highlight on yank
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
-- highlight lualine inactive buffer / window sepeartor
vim.api.nvim_create_autocmd({'VimEnter', 'BufEnter'}, {
-- vim.api.nvim_create_autocmd({'ColorScheme'}, {
  callback = function()
    -- local frappe = require("catppuccin.palettes").get_palette("frappe")
    vim.cmd.hi('lualine_a_inactive                     guibg=#252736')
    vim.cmd.hi('lualine_b_inactive                     guibg=#252736')
    vim.cmd.hi('lualine_c_inactive                     guibg=#252736')
    vim.cmd.hi('lualine_x_filetype_DevIconLua_inactive guibg=#252736')
    vim.cmd.hi('lualine_x_filetype_DevIconTxt_inactive guibg=#252736')
    vim.cmd.hi('WinSeparator                           guibg=#252736')
  end,
  group = highlight_group,
  pattern = '*',
})
-- highlight cursorline in replace-mode
vim.api.nvim_create_autocmd('ModeChanged', {
  callback = function()
    local m = vim.api.nvim_get_mode()
    local frappe = require("catppuccin.palettes").get_palette("frappe")
    if m.mode == 'R' then
      -- vim.cmd.hi('CursorLine guibg=#55262E') -- #guibg=#3b3f52
      -- vim.cmd.hi('CursorLine guibg=#4E2D33') -- #guibg=#3b3f52
      -- vim.cmd.hi('CursorLine guibg=#B13F52') -- #guibg=#3b3f52
      vim.cmd.hi('CursorLine guibg=#8F3947') -- #guibg=#3b3f52
    elseif m.mode == 'i' then
      vim.cmd.hi('CursorLine guibg=#3B3F5A') -- guifg=#ffffff 
    else
      vim.cmd.hi('CursorLine guibg=#3b3f52') -- guifg=#ffffff 
    end
    -- print(m.mode)
    -- require('fidget').notify("mode: "..m.mode)
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- vert split seperator bars character
vim.cmd('set fillchars+=vert:\\ ')

-- set replace-mode cursor to be full as well, like normal-mode 
-- default: "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.o.guicursor = "r-cr-n-v-c-sm:block,i-ci-ve:ver25,o:hor20"

-- set gui font, aka. for nvim-qt
vim.o.guifont = "JetBrainsMono Nerd Font Mono:h11"

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- highlight cursor line 
vim.wo.cursorline = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


-- [[ configure neotree ]]

-- -- old function used to open neotree in its own window
-- Neotree_open = false
-- Neotree_buf  = -1
-- Neotree_win  = -1
-- local function neotree_toggle()
--   -- print('neotree_open: '..tostring(Neotree_open)..', win: '..tostring(Neotree_win)..', buf: '..tostring(Neotree_buf))
-- 
--   -- if window already openend swicth to that window
--   -- else create new neotree window 
--   if Neotree_open and vim.api.nvim_win_is_valid(Neotree_win) and vim.api.nvim_buf_is_valid(Neotree_buf) then
--     vim.api.nvim_set_current_win(Neotree_win)
--   else
--     vim.cmd("tabnew")
--     Neotree_buf = vim.api.nvim_get_current_buf()
--     Neotree_win = vim.api.nvim_get_current_win()
--     vim.cmd("Neotree position=current")
--     Neotree_open = true
--     -- autoclose neotree on exiting
--     vim.api.nvim_create_autocmd('ExitPre', {
--       callback = function()
--         if Neotree_open and vim.api.nvim_win_is_valid(Neotree_win) and vim.api.nvim_buf_is_valid(Neotree_buf) then
--           vim.api.nvim_buf_delete(Neotree_buf)
--           vim.api.nvim_win_close(Neotree_win, true)
--         end
--       end
--     })
--   end
-- end
-- vim.keymap.set("n", "<C-d>", neotree_toggle, {  noremap = true, desc = ''})

-- open neotree in float
-- vim.keymap.set('n', '<C-d>', 'Neotree position=float toggle',
--                { desc = "Open neo-tree in float" } )
-- open neotree in float and expand to current file
vim.keymap.set('n', '<C-d>', function()
    local reveal_file = vim.fn.expand('%:p')
    if (reveal_file == '') then
      reveal_file = vim.fn.getcwd()
    else
      local f = io.open(reveal_file, "r")
      if (f) then
        f.close(f)
      else
        reveal_file = vim.fn.getcwd()
      end
    end
    require('neo-tree.command').execute({
      -- action = "focus",          -- OPTIONAL, this is the default value
      -- source = "filesystem",     -- OPTIONAL, this is the default value
      position = "float",
      reveal_file = reveal_file, -- path to file or folder to reveal
      -- reveal_force_cwd = true,   -- change cwd without asking if needed
      toggle = true,
    })
  end,
  { desc = "Open neo-tree at current file or working directory" }
)


-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  extensions = {
  },
  defaults = {
    file_ignore_patterns = {
      ".git\\", ".vs\\", ".cache\\", ".git/", ".vs/", ".cache/",
      "_bin\\", "_bin/", "bin\\", "bin/",
      -- "%.o",
      "%.zip",
      "%.tex","%.mesh",
      "%.swp", "%.un~", "%.*%~" },
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-s>'] = 'select_horizontal',  -- open in horizontal split
        ['<C-y>'] = 'select_horizontal',  -- open in horizontal split
        ['<C-x>'] = 'select_vertical',    -- open in vertical split
        -- opn in tab is <C-t>
      },
    },
    -- prompt_prefix = "❯ ",
    -- selection_caret = "❯ ",
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?',       require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
-- vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
-- vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader><space>', require('telescope-tabs').list_tabs, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find( {} )
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'live grep in open files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files,           { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin,     { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files,   { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>f',  require('telescope.builtin').find_files,  { desc = 'search [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags,   { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep,   { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>',                   { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>q',  require('telescope.builtin').diagnostics, { desc = 'search diagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume,      { desc = '[S]earch [R]esume' })

-- [[ session-lens keymaps ]]
-- vim.keymap.set('n', '<leader>S', require('session-lens').search_session,    { desc = 'search [S]essions' })
vim.keymap.set('n', '<leader>S', '<cmd>SessionSearch<CR>',    { desc = 'search [S]essions' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'lua', 'vimdoc', 'vim', 'odin', 'glsl' }, -- 'gitignore', 'make', 'zig', 'bash', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'go'

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- List of parsers to ignore installing
    ignore_install = {},
    -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
    modules = {},
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>r', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  -- nmap('GD', ":vsplit<CR>gd", "[G]oto [D]efinition, in vert split")
  nmap('GD', ':vsplit | lua vim.lsp.buf.definition()<CR>', '[G]oto [D]efinition, in vsplit') -- https://neovim.discourse.group/t/jump-to-definition-in-vertical-horizontal-split/2605/2
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynmic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  -- done with "lewis6991/hover.nvim" now
  -- nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}
-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work
require('which-key').register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
-- require('mason-lspconfig').setup()
require("mason-lspconfig").setup {
    ensure_installed = { "clangd", "ols", "lua_ls" },
}
require('mason-lspconfig').setup_handlers {
  function (server_name) -- default handler (optional)
      require("lspconfig")[server_name].setup {}
  end,
}

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- ols    = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = false; -- disable lsp snippets
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = false; -- disable lsp snippets

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
      icons_enabled = true,
    }
  end,
}

-- lsp diagnostic display settings
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  -- update_in_insert = false,
  -- severity_sort = false,
})
-- lsp error, warning, info, etc, icons
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- [[ dap ]] 

require("mason-nvim-dap").setup({ ensure_installed = { "cppdbg" } })
-- require("dapui").setup()

-- [[dap-config]] debug adapter config
-- set breakpoint char, see :h dap.txt -> SIGNS CONFIGURATION
vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
-- open/close dap-ui automatically
-- dont close if the debugged executable exited with error code
local dap, dapui = require("dap"), require("dapui")
_Dap_rtn_code = 0
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
  _Dap_rtn_code = 0
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
  _Dap_rtn_code = 0
end
dap.listeners.before.event_terminated.dapui_config = function()
  if _Dap_rtn_code == 0 then
    dapui.close()
    -- require('fidget').notify("terminated")
  end
end
dap.listeners.before.event_exited.dapui_config = function(session, body)
  -- print('Session terminated', vim.inspect(session), vim.inspect(body))
  -- require('fidget').notify('Session terminated: '..vim.inspect(session)..", "..vim.inspect(body))
  require('fidget').notify("exit code: "..body.exitCode)
  _Dap_rtn_code = body.exitCode
  if body.exitCode == 0 then
    dapui.close()
  else
    dapui.open()
  end
end
-- close dapui before closing so session doesnt save it
vim.api.nvim_create_autocmd('ExitPre', { callback = function() dapui.close() end })

-- setup dap adapters
dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = 'C:\\#terminal_extensions\\cpptools-win64\\debugAdapters\\bin\\OpenDebugAD7.exe',
	-- command = vim.fn.exepath('OpenDebugAD7'),
  options = {
    detached = false
  },
}
-- setup dap languages
dap.configurations.c = {
  {
    name = "Launch file",
    type = "cppdbg",
    request = "launch",
    program = function()
      -- return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '\\_bin\\editor', 'file')
      -- open executable specified in 'dap_path' file or promt for input
      local f = io.open( vim.fn.getcwd().."\\dap_path", "rb")
      if f then
        local txt = f:read()
        f:close()
        -- vim.cmd("!build") -- call build command
        -- vim.cmd("ToggleTerm<CR>build<CR>")
        -- vim.api.nvim_command("!build")
        require('fidget').notify("debugging: "..vim.fn.getcwd()..'\\'..txt)
        return vim.fn.getcwd()..'\\'..txt
      else
        return vim.fn.input('Path to executable: ', vim.fn.getcwd()..'\\', 'file')
      end
    end,
    cwd = '${workspaceFolder}',
    stopAtEntry = false,
  },
  -- {
  --   name = 'Attach to gdbserver :1234',
  --   type = 'cppdbg',
  --   request = 'launch',
  --   MIMode = 'gdb',
  --   miDebuggerServerAddress = 'localhost:1234',
  --   miDebuggerPath = '/usr/bin/gdb',
  --   cwd = '${workspaceFolder}',
  --   program = function()
  --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
  --   end,
  -- },
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.odin = dap.configurations.c -- @TODO: get this working


-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- [[ gui nvim qt ]]
if vim.fn.has('gui_running') == 1 then
  require('fidget').notify( "vim.fn.has('gui_running'):"..vim.fn.has('gui_running') )
  -- Neovide specific
  if vim.g.neovide == true then
    vim.g.neovide_fullscreen = true
  end
  --require('session-lens').search_session()
  -- vim.api.nvim_create_autocmd('UIEnter', {
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      -- vim.cmd("<cmd>SessionSearch<CR>")
      vim.cmd("SessionSearch")
      require('fidget').notify( "called session search")
    end,
    -- pattern = '*',
  })
end
-- vim.keymap.set('n', '<c-w>f', ':call GuiWindowFullScreen((g:GuiWindowFullScreen + 1) % 2)<CR>', { desc= "toggle fullscreen" })
-- vim.keymap.set('n', '<F11', ':call GuiWindowFullScreen((g:GuiWindowFullScreen + 1) % 2)<CR>', { desc= "toggle fullscreen" })
-- Neovide specific
if vim.g.neovide == true then
    vim.keymap.set({'n'}, '<F11>',
        function()
            if vim.g.neovide_fullscreen == false then
                vim.g.neovide_fullscreen = true
            else
                vim.g.neovide_fullscreen = false
            end
        end,
        { silent = true }
    )
end


