local M = {}
-- module content will be here
function M.init_highlights()
  vim.api.nvim_command('highlight default HighlightLine guifg=#ff007c gui=bold ctermfg=198 cterm=bold ctermbg=darkgreen')
  namespace_id = vim.api.nvim_create_namespace('HihglightLineNamespace') 
end
function M.run_autocommands()
   vim.api.nvim_command('augroup HighlightLine')
   vim.api.nvim_command('autocmd!')
   vim.api.nvim_command("autocmd ColorScheme * lua require'highlights'.init_highlights()")
   vim.api.nvim_command('augroup end')
end
function M.highlight()
  -- dynamic highlighting logic is here
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()
  
  vim.api.nvim_buf_set_extmark(current_buf, namespace_id, row, start_col, {end_row = row, end_col = end_col, hl_group='HighlightLine'})
end
return M
