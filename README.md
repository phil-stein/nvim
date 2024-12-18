
# neovim config

config based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) <br>

font: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono <br>

<img src="https://github.com/phil-stein/nvim/blob/main/screenshot_01.PNG" alt="screenshot" width="800"> <br>

## setup
```
make backup of nvim folder first, if already exists
windows: 
  >cd %appdata%\..\local\nvim
linux:
  cd into nvim directory
  
>git clone https://github.com/phil-stein/nvim 

>nvim
  -> :Lazy
  -> :checkhealth
  -> :Mason
    -> (2)LSP -> clangd   press i
    -> (3)DAP -> cpptools press i
```

## themes
- _deactivated_ [onedark](https://github.com/navarasu/onedark.nvim)
- [catpuccin](https://github.com/catppuccin/nvim)

## plug-ins
- [lazy.nvim](https://github.com/folke/lazy.nvim) | plug-in manager
- [mason](https://github.com/williamboman/mason.nvim) | lsp-, linter-manager
	- [mason-lsp-config](https://github.com/williamboman/mason-lspconfig.nvim) | lsp configs for mason
  - [mason-nvim-dap](https://github.com/jay-babu/mason-nvim-dap.nvim) | dap adapters for mason
- [nvim-dap](https://github.com/mfussenegger/nvim-dap) | dap, debuggger
  - [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | ui interface for dap debugging
  - [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | virtual text showing variable values
- [telescope](https://github.com/nvim-telescope/telescope.nvim) | file-navigation
	- ripgrep
	- plenary
	- telescope-fzf-native | fuzzy finder
	- _diasbled_ [telescope-file-browser](https://github.com/nvim-telescope/telescope-file-browser.nvim) | file browser
  - [telescope-tabs](https://github.com/LukasPietzschmann/telescope-tabs)
- [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) 
- [devicons](https://github.com/ryanoasis/vim-devicons) | use nerd-fonts for icons
- [lualine](https://github.com/nvim-lualine/lualine.nvim) | better commandline, tab-line
- [fine-cmdline](https://github.com/VonHeikemen/fine-cmdline.nvim) | floating commandline
	- [nui.nvim](https://github.com/MunifTanjim/nui.nvim/tree/main) | ui-library, required by fine-cmdline
- _disabled_ [vim-floatterm](https://github.com/voldikss/vim-floaterm) | floating terminal
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | floating terminal
- [vimwiki](https://github.com/vimwiki/vimwiki) | notes, etc.
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | code-completion
	- luasnip | snippets
- [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | tab-line
- [which-key.nvim](https://github.com/folke/which-key.nvim) | show keymaps while typing them
- git stuff
  - gitsigns
  - [vim-fugitive](https://github.com/tpope/vim-fugitive) | :Git or :G
  - 'tpope/vim-rhubarb'
- [fidget.nvim](https://github.com/j-hui/fidget.nvim) | lsp status updates
- [neodev.nvim](https://github.com/folke/neodev.nvim) | init.lua and plug-in dev helper
- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
- [Comment.nvim](https://github.com/numToStr/Comment.nvim) | hotkeys for commenting
- [vim-glsl](https://github.com/tikhomirov/vim-glsl) | glsl-highlighting
- [hover.nvim](https://github.com/lewis6991/hover.nvim) | better 'K' documentation
- [modicator.nvim](https://github.com/mawkler/modicator.nvim) | hange line number to reflect current mode
- _disabled_ [trouble.nvim](https://github.com/folke/trouble.nvim) | show diagnostics list
- [auto-session](https://github.com/rmagatti/auto-session) | save and load sessions based on cwd
  - [session-lens](https://github.com/rmagatti/session-lens) | view sessions using telescope
- [neotree](https://github.com/nvim-neo-tree/neo-tree.nvim) | file explorer

## commands
- :Lazy             -> open plugin manager ui
- :Mason            -> open mason ui
- :checkhealth      -> check plug-in errors & warnings
- :LspInfo          -> info about current lsp, including id
- :LspRestart [id]  -> restart lsp, can give id
- :Git or :G        -> git command
- :WQ               -> :wqall, but works with terminals
- :Doc ...          -> open floating window with [term_docs]() documentation
- :Hex              -> %!xxd turns text to hex representation, activates syntax highlighting
- :Unhex            -> %!xxd -r turns hex representation to text

## hotkeys
- telescope
	- ? (normal)			-> help / key mappings
	- C-s  						-> open in horizontal split
	- C-x  						-> open in vertical split
	- C-t  						-> open in tab
	- leader S				-> search sessions 
	- leader f				-> search files
	- leader ?        -> search recently opened
	- leader space    -> search open buffers
	- leader /				-> search keyword, fuzzyfind
	- leader gf			  -> search git files
- file browser
  - C-d						  -> toggle file broswer
- lsp
	- leader r 	  		-> rename
	- gd							-> goto defenition
	- GD              -> open defenition in vsplit
	- gD							-> goto declaration
	- gI							-> goto implementation
	- leader D				-> goto type defenition
  - leader e        -> show diagnostic message
  - leader q        -> show diagnostic message list
- float-term 
	- C-t	            -> toggle terminal
	- C-b						  -> run build   | for running build batch / bash / powershell file
	- _disabled_ C-B						-> run build - | can check in batch file for arg and build different proj
- code-completion
	- CR						  -> accept completion
	- Tab		  			  -> cycle through completions
- hover
	- K								-> hover documentation
	- gK							-> hover documentation selection
	- C-n						  -> next
	- C-p						  -> previous
- dap | debugging
  - F4             -> end debuggger
  - F5             -> run debuggger
  - F6             -> step into
  - F7             -> step over
  - F8             -> step out
  - leader b       -> toggle breakpoint,
  - leader gb      -> run debugger, break at cursor
  - leader dr      -> open repl,
  - leader d       -> open debug ui, opens automatically
  - leader d       -> show info about word under cursor
- comment
  - gcc             -> line toggle comment
  - gbc             -> line toggle multiline-comment
  - gc in visual m. -> tine toggle comment
  - gb in visual m. -> line toggle multiline-comment

