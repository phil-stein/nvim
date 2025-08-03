
--
-- [[ custom terminal ]]
--

---@enum TerminalType
TerminalType = { NORMAL=1, PYTHON=2, SPOTFY=3 }
local term = {}
-- local py_term = {}
-- local sptfy_term = {}

-- ---@type { [TerminalType]: { type: TerminalType, buf: integer, job_id: any, popup: any, popup_open: boolean } }
-- local term = {}

local popup_open = false
local popup = nil
local function open_popup()
  local Popup = require("nui.popup")
  popup = Popup({
    position = "50%",
    size = {
      width  = 0.5,
      height = 0.85,
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
        top = " törminal ",
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
  popup:show()
  popup_open = true

  vim.cmd('terminal')
  local buf = vim.api.nvim_get_current_buf()
  local job_id = vim.b[buf].terminal_job_id,

  -- _close popup when leaving it
  popup:on({ require("nui.utils.autocmd").event.BufLeave, require("nui.utils.autocmd").event.BufHidden },
    function()
      -- popup:unmount()
      popup:hide()
    end ) -- { once = true })
  popup:on({ require("nui.utils.autocmd").event.BufDelete, require("nui.utils.autocmd").event.ExitPre },
    function()
      popup:unmount()
    end, { once = true })

  vim.cmd('startinsert')

  return { buf=buf, job_id=job_id }
end

function Term_toggle_func(opts, type)
  if popup == nil then
    term = open_popup()
    popup_open = true
  elseif popup_open then
    popup:hide()
    popup_open = false
  else
    popup:show()
    popup_open = true
  end

  if popup_open then
    -- vim.cmd('startinsert')
    if opts ~= nil then
      local count = 0
      for _ in pairs(opts.fargs) do count = count + 1 end
      print( "count: "..count )
      require('fidget').notify( "count: "..count )
      if count > 0 then
        local str = table.concat(opts.fargs, ' ')
        print( "args: "..str )
        require('fidget').notify( "args: "..str )
        vim.cmd( 'set modifiable' )

        vim.cmd( 'startinsert' )
        vim.cmd( 'g$' ) -- goto end of line

        Term_send( term.job_id, str )
      end
    end
  end
end
vim.api.nvim_create_user_command('Term', function(opts) Term_toggle_func(opts, TerminalType.NORMAL) end,
{ nargs = '*', desc = ':Term -> toggle normal terminal'})
vim.keymap.set('n', '<C-t>', function() vim.cmd('Term') end, { silent = true, desc = ":Term -> open/close terminal"})
vim.keymap.set('t', '<C-t>', function() vim.cmd('Term') end, { silent = true, desc = ":Term -> open/close terminal"})
vim.keymap.set('v', '<C-t>', function() vim.cmd('Term') end, { silent = true, desc = ":Term -> open/close terminal"})
vim.keymap.set('x', '<C-t>', function() vim.cmd('Term') end, { silent = true, desc = ":Term -> open/close terminal"})
vim.api.nvim_create_user_command('TermPy', function(opts) Term_toggle_func(opts, TerminalType.PYTHON) end,
{ nargs = '*', desc = ':TermPy -> toggle python terminal'})

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
    require('fidget').notify( "filetype: "..vim.bo.filetype )
    -- require('notify')( "filetype: "..vim.bo.filetype )
      vim.cmd( ':Typora' )
    else
      vim.cmd( 'Term build\r')
    end
  end,
  { silent = true , desc = "call build batch/bash file or open .md files in typora"})

-- [[ :Typora command ]]
-- typora | Typora, custom hotkey to open current file in typora
vim.api.nvim_create_user_command('Typora',
  function()
    -- vim.cmd( "!typora %" )
    -- vim.cmd( ":ToggleTerm<CR>typora %<CR>" )
    -- vim.cmd( 'TermExec cmd="taskkill /F /IM Typora.exe"')
    vim.cmd( '!taskkill /F /IM Typora.exe')
    -- vim.cmd( 'TermExec cmd="Typora %"')
    -- vim.cmd( "ToggleTerm" )
    vim.cmd( 'Term Typora '..vim.fn.expand('%')..' \r')
  end,
  {  nargs = 0, desc = ''})


