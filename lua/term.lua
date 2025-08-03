
--
-- [[ custom terminal ]]
--

local term = {}
local py_term = {}

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
  local buf = api.nvim_get_current_buf()
  local job_id = vim.b[buf].terminal_job_id,

  p  -- _close popup when leaving it
  local event = require("nui.utils.autocmd").event
  popup:on({ event.BufLeave, event.BufHidden },
    function()
      -- popup:unmount()
      popup:hide()
    end ) -- { once = true })
  popup:on({ event.BufDelete, event.ExitPre },
    function()
      popup:unmount()
    end, { once = true })

  -- local jobID = vim.fn.jobstart( 'cmd', { pty = true } )
  vim.cmd('startinsert')

  return { buf=buf, job_id=job_id }
end

vim.api.nvim_create_user_command('Term',
  function(opts)
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
          local str = table.concat(opts.fargs)
          print( "args: "..str )
          require('fidget').notify( "args: "..str )
          vim.cmd( 'set modifiable' )

          vim.cmd( 'startinsert' )
          vim.cmd( 'g$' ) -- goto end of line

          -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          -- require('fidget').notify( 'col: '..col..', row: '..row )
          -- -- Notice the uuid is given as an array parameter, you can pass multiple strings.
          -- -- Params 2-5 are for start and end of row and columns.
          -- -- See earlier docs for param clarification or `:help nvim_buf_set_text.
          -- vim.api.nvim_buf_set_text(0, row -1, col +1, row -1, col +1, { str })
          term_send( term.job_id, str )
        end
      end
    end

    -- if popup_openend == false then
    --   vim.cmd('terminal')
    -- end
    -- vim.cmd('startinsert')

  end,
{ nargs = '*', desc = ''})
-- end doc cmd
vim.keymap.set('n', '<C-t>', function() vim.cmd('Term') end, { silent = true, desc = ":Term -> open/close terminal"})
vim.keymap.set('t', '<C-t>', function() vim.cmd('Term') end, { silent = true, desc = ":Term -> open/close terminal"})

local function term_send(job_id, cmd)
  cmd = type(cmd) == "table" and with_cr(self.newline_chr, unpack(cmd))
    or with_cr(self.newline_chr, cmd --[[@as string]])
  vim.fn.chansend(job_id, cmd)
end


-- [[ Ctrl - b -> build project or open in appropriate software ]]
vim.keymap.set('n', '<C-b>',
  function()
    if (vim.bo.filetype == "markdown") then
    require('fidget').notify( "filetype: "..vim.bo.filetype )
    -- require('notify')( "filetype: "..vim.bo.filetype )
      vim.cmd( ':Typora' )
    else
      -- vim.cmd( ':ToggleTerm<CR>build<CR>' )
      -- vim.cmd( 'TermExec cmd="build"')
      vim.cmd( 'Term build')
    end
  end,
  { silent = true , desc = "call build batch/bash file or open .md files in typora"})


