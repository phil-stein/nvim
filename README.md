
# neovim config

config based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)

## themes
	* [onedark](https://github.com/navarasu/onedark.nvim)

## plug-ins
	* [lazy.nvim](https://github.com/folke/lazy.nvim) | plug-in manager
	* [mason](https://github.com/williamboman/mason.nvim) | lsp-, linter-manager
		* [mason-lsp-config](https://github.com/williamboman/mason-lspconfig.nvim) | lsp configs for mason
	* [telescope](https://github.com/nvim-telescope/telescope.nvim) | file-navigation
	* [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) 
	* [devicons](https://github.com/ryanoasis/vim-devicons) | use nerd-fonts for icons
	* [lualine](https://github.com/nvim-lualine/lualine.nvim) | better commandline
	* [fine-cmdline](https://github.com/VonHeikemen/fine-cmdline.nvim) | floating commandline
		* [nui](https://github.com/MunifTanjim/nui.nvim/tree/main) | ui-library, required by fine-cmdline
	* [vim-floatterm](https://github.com/voldikss/vim-floaterm) | floating terminal
	* [winwiki](https://github.com/vimwiki/vimwiki) | notes, etc.
	* [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | code-completion
		* luasnip | snippets, disabled
	* [barbar.nvim](https://github.com/romgrk/barbar.nvim) | tab-line 
	* which-key.nvim | show keymaps while typing them
	* indent-blankline.nvim
	* Comment.nvim

## commands
	* :Lazy        -> open plugin manager ui
	* :Mason       -> open mason ui
	* :checkhealth -> check plug-in errors & warnings

## hotkeys
	* telescope
		* <C-s>		  -> open in horizontal split
		* <C-x>   	  -> open in vertical split
		* <C-t>   	  -> open in tab
		* <leader>sf      -> search files
		* <leader>?       -> search recently opened
		* <leader><space> -> search open buffers
		* <leader>/	  -> search keyword, fuzzyfind
		* <leader>gf	  -> search git files
	* lsp
		* <leader>rn	  -> rename
		* gd		  -> goto defenition
		* GD              -> open defenition in vsplit
		* gD		  -> goto declaration
		* gI		  -> goto implementation
		* <leader>D	  -> goto type defenition
		* K		  -> hover documentation
	* float-term 
		* <C-t>	          -> toggle terminal
	* code-completion
		* <CR>		  -> accept completion
		* <Tab>		  -> cycle through completions

