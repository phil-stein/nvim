
--
-- [[ custom terminal ]]
--

---@enum TerminalType
TerminalType = { NORMAL=1, PYTHON=2, SPOTIFY=3 }
-- local term = {}
-- local py_term = {}
-- local sptfy_term = {}

-- local popup_open = false
-- local popup = nil

---@class Term { type: TerminalType, buf: integer, job_id: any, popup: require("nui.popup").NuiPopup, popup_open: boolean }
local Term = { type=TerminalType.NORMAL, buf=0, job_id=-1, popup=nil, popup_open=false }

---@type { [TerminalType]: { t: Term } }
local terms = {
  { type=TerminalType.NORMAL,  win=-1, buf=-1, job_id=-1, popup=nil, popup_open=false, title=" törminal ",     width=0.5, height=0.85, row="50%", col="50%" },
  { type=TerminalType.PYTHON,  win=-1, buf=-1, job_id=-1, popup=nil, popup_open=false, title=" peißun ",       width=0.2, height=0.85, row="50%", col="98%" },
  { type=TerminalType.SPOTIFY, win=-1, buf=-1, job_id=-1, popup=nil, popup_open=false, title=" schpottiefei ", width=0.3, height=0.85, row="50%", col="02%" },
}

---@param type TerminalType
function Term_open_popup( type )
  local Popup = require("nui.popup")
  terms[type].popup = Popup({
    position = { -- "50%",
      row = terms[type].row,
      col = terms[type].col,
    },
    size = {
      width  = terms[type].width,  -- 0.5,
      height = terms[type].height, -- 0.85,
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
        top = terms[type].title, -- " törminal ",
        top_align = "center",
      },
    },
    buf_options = {
      modifiable = true,
      readonly = false,
    },
    win_options = {
      winblend = 0,
      -- winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  })
  -- popup:mount()
  terms[type].popup:show()
  terms[type].popup_open = true

  vim.cmd('terminal')
  local buf = vim.api.nvim_get_current_buf()
  local job_id = vim.b[buf].terminal_job_id
  terms[type].buf = buf
  terms[type].job_id = job_id
  terms[type].win = vim.api.nvim_get_current_win()
  -- require('fidget').notify( "nvim-win-id: "..tostring(vim.api.nvim_get_current_win()) )
  vim.notify( "nvim-win-id: "..tostring(vim.api.nvim_get_current_win()) )

  -- set terminal to type needed
  if     type == TerminalType.PYTHON  then Term_send( job_id, "py\r" )
  elseif type == TerminalType.SPOTIFY then Term_send( job_id, "sptfy\r" )
  end

  -- _close popup when leaving it
  -- terms[type].popup:on({ require("nui.utils.autocmd").event.BufLeave, require("nui.utils.autocmd").event.BufHidden },
  --   function()
  --     terms[type].popup:hide()
  --   end ) -- { once = true })
  terms[type].popup:on({ require("nui.utils.autocmd").event.BufDelete, require("nui.utils.autocmd").event.ExitPre },
    function()
      -- if terms[TerminalType.SPOTIFY].popup ~= nil then
      --   -- Term_open( TerminalType.SPOTIFY, false )
      --   Term_send( terms[TerminalType.SPOTIFY].job_id, "q" )
      -- end
      -- if terms[TerminalType.PYTHON].popup ~= nil then
      --   -- Term_open( TerminalType.PYTHON, false )
      --   Term_send( terms[TerminalType.PYTHON].job_id, "^Z\r" )
      -- end
      terms[type].popup:unmount()
    end, { once = true })

  vim.cmd('startinsert')

  return { buf=buf, job_id=job_id }
end
-- @TODO: try this to close terms running sptfy or py
-- function Term_close_buffer(  )
--   vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
--   if vim.api.nvim_buf_is_loaded(bufnr) then
--     vim.api.nvim_buf_delete(bufnr, { force = true })
--   end
--   if vim.api.nvim_win_is_valid(win_id) then
--     vim.api.nvim_win_close(win_id, true)
--   end
-- end

-- vim.api.nvim_create_autocmd({'ExitPre'}, { -- TermClose
--   callback = function()
--     if terms[TerminalType.SPOTIFY].popup ~= nil then
--       -- -- vim.cmd( "close! "..terms[TerminalType.SPOTIFY].buf )
--       -- vim.api.nvim_win_close( terms[TerminalType.SPOTIFY].win, true )
--       -- vim.cmd( terms[TerminalType.SPOTIFY].buf.."bw!" )
--       Term_open( TerminalType.SPOTIFY )
--       Term_send( terms[TerminalType.SPOTIFY].job_id, "q" )
--     end
--     if terms[TerminalType.PYTHON].popup ~= nil then
--       -- -- vim.cmd( "close! "..terms[TerminalType.].buf )
--       -- vim.api.nvim_win_close( terms[TerminalType.PYTHON].win, true )
--       Term_open( TerminalType.PYTHON )
--       Term_send( terms[TerminalType.PYTHON].job_id, "^Z\r" )
--     end
--   end,
-- })

function Term_toggle( opts, type, close_all_others )
  if close_all_others then
    for k, v in pairs(terms) do
      if k ~= type and v.popup_open then
        Term_toggle_func( nil, k )
      end
    end
  end
  Term_toggle_func( opts, type )
end
function Term_toggle_func( opts, type )
  if terms[type].popup == nil then
    local _term = Term_open_popup(type)
    terms[type].buf    = _term.buf
    terms[type].job_id = _term.job_id
    terms[type].popup_open = true
  elseif terms[type].popup_open then
    terms[type].popup:hide()
    terms[type].popup_open = false
  else
    terms[type].popup:show()
    terms[type].popup_open = true
  end

  if terms[type].popup_open then
    vim.cmd('startinsert')
    if opts ~= nil then
      local count = 0
      for _ in pairs(opts.fargs) do count = count + 1 end
      -- print( "count: "..count )
      -- require('fidget').notify( "count: "..count )
      if count > 0 then
        local str = table.concat(opts.fargs, ' ')
        -- print( "args: "..str )
        -- require('fidget').notify( "args: "..str )
        vim.cmd( 'set modifiable' )

        vim.cmd( 'startinsert' )
        vim.cmd( 'normal G' ) -- goto end of line

        Term_send( terms[type].job_id, str )
      end
    end
  end
end

---@param type TerminalType
---@param close_all_others boolean
function Term_open( type, close_all_others )
  if not terms[type].popup_open then
    Term_toggle( nil, type, close_all_others )
  end
end
---@param type TerminalType
---@param close_all_others boolean
function Term_close( type, close_all_others )
  if terms[type].popup_open then
    Term_toggle( nil, type, close_all_others )
  end
end

---@param mapping string
---@param cmd string
---@param _desc string
function Term_set_mapping( mapping, cmd, _desc )
  vim.keymap.set('n', mapping, function() vim.cmd(cmd) end, { silent = true, desc = _desc })
  vim.keymap.set('t', mapping, function() vim.cmd(cmd) end, { silent = true, desc = _desc })
  vim.keymap.set('v', mapping, function() vim.cmd(cmd) end, { silent = true, desc = _desc })
  vim.keymap.set('x', mapping, function() vim.cmd(cmd) end, { silent = true, desc = _desc })
end

vim.api.nvim_create_user_command('Term', function(opts) Term_toggle( opts, TerminalType.NORMAL, false ) end,
{ nargs = '*', desc = ':Term -> toggle normal terminal'})
Term_set_mapping( '<C-t>', 'Term', ":Term -> open/close terminal" )

vim.api.nvim_create_user_command('TermPy', function(opts) Term_toggle( opts, TerminalType.PYTHON, false ) end,
{ nargs = '*', desc = ':TermPy -> toggle python terminal'})
Term_set_mapping( '<C-p>', 'TermPy', ":TermPy -> toggle python terminal" )

vim.api.nvim_create_user_command('TermSptfy', function(opts) Term_toggle( opts, TerminalType.SPOTIFY, false ) end,
{ nargs = '*', desc = ':TermSptfy -> toggle spotify terminal'})
Term_set_mapping( '<C-s>', 'TermSptfy', ":TermSptfy -> toggle spotify terminal" )

-- @TODO: 
-- - <C-t> Term doesnt close TermPy, etc. before toggeling same otherway around 
-- - ? put python and spotify terminals in different places , like left/right next to normal
--  - ? scale terminals based on how many open at once


function Term_send(job_id, cmd)
  cmd = type(cmd) == "table" and With_cr('\r', unpack(cmd))
    or With_cr('\r', cmd --[[@as string]])
  vim.fn.chansend(job_id, cmd)
end
---stoled from toggleterm.nvim, idk why this exist, but finally confinced lua to do anything, so idc u know
---Combine arguments into strings separated by new lines
---@vararg string
---@param newline_chr string
---@return string
function With_cr(newline_chr, ...)
  local result = {}
  for _, str in ipairs({ ... }) do
    table.insert(result, str .. newline_chr)
  end
  return table.concat(result, "")
end


-- [[ Ctrl - b -> build project or open in appropriate software ]]
vim.keymap.set('n', '<C-b>',
  function()
    if (vim.bo.filetype == "markdown") then
      vim.notify( "filetype: "..vim.bo.filetype )
      vim.cmd( 'Typora' )
      vim.notify( 'called Typora via Ctrl-B' )
      vim.cmd( 'Term' )
      -- @TODO: make TermClose/Open commands
    elseif (vim.bo.filetype == "lua") then
      vim.cmd( 'source %' )
      vim.notify( 'sourced current file' )
    else
      vim.notify( 'Ctrl-B -> build' )
      if (vim.fn.has('macunix')) then
        vim.cmd( 'Term bash build.sh\r')
      else
        vim.cmd( 'Term build\r')
      end
    end
  end,
  { silent = true , desc = "call build batch/bash file or open .md files in typora"})

-- [[ :Typora command ]]
-- typora | Typora, custom hotkey to open current file in typora
vim.api.nvim_create_user_command('Typora',
  function()
    vim.notify( 'called Typora' )
    -- vim.cmd( "!typora %" )
    -- vim.cmd( ":ToggleTerm<CR>typora %<CR>" )
    -- vim.cmd( 'TermExec cmd="taskkill /F /IM Typora.exe"')
    vim.cmd( '!taskkill /F /IM Typora.exe')
    -- vim.cmd( 'TermExec cmd="Typora %"')
    -- vim.cmd( "ToggleTerm" )
    vim.cmd( 'Term Typora '..vim.fn.expand('%')..' \r')
  end,
  {  nargs = 0, desc = ''})


