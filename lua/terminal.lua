local terminal = {}

function terminal:test()
  print("hello")
end

local Popup = require("nui.popup")
local popup = Popup({
  position = "50%",
  size = {
    width  = 0.6,
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
      top = " terminal ",
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
local term_open = false

function terminal:toggle_terminal()

  if term_open then
    popup:hide()
    term_open = false
  else
    popup:show()
    term_open = true
  end

  -- close popup when leaving it
  local event = require("nui.utils.autocmd").event
  popup:on({ event.BufLeave, event.BufDelete, event.BufHidden },
    function()
      popup:unmount()
    end, { once = true })

  -- quit with esc or q
  -- popup:map("t", "<esc>", function() vim.cmd('q!') popup:unmount() end)
  -- popup:map("t", "q",     function() vim.cmd('q!') popup:unmount() end)
  popup:map("t", "<esc>", function() terminal:toggle_terminal() end)
  popup:map("t", "q",     function() terminal:toggle_terminal() end)

  -- vim.cmd('term '..cmd)
  vim.cmd('term')
  vim.cmd('startinsert')
end

return terminal
