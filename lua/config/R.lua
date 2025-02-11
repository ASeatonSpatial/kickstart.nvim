-- R keybinds
--
-- Open R terminal split
vim.keymap.set('n', '<leader>rs', ':split | terminal R<CR>G<C-w>k', { desc = '[O]pen R terminal' })

-- Slime things
--- If an R terminal has been opened, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
local function send_cell()
  if vim.b['quarto_is_r_mode'] == nil then
    vim.fn['slime#send_cell']()
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.fn['slime#send_cell']()
  end
end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
local function send_region()
  -- Check if we are in visual mode
  if vim.fn.visualmode() == '' then
    -- If not in visual mode, select the current line
    vim.cmd 'normal! V'
  end

  -- If filetype is not quarto, just send the region
  if vim.bo.filetype ~= 'quarto' or vim.b['quarto_is_r_mode'] == nil then
    vim.cmd('normal' .. slime_send_region_cmd)
    return
  end

  -- Handle Quarto R mode
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'

    -- If we're in Python, start reticulate if not already running
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end

    -- If we're not in Python and reticulate is running, exit reticulate
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end

    -- Send the region (or the selected line)
    vim.cmd('normal' .. slime_send_region_cmd)
  end
end

local function send_code()
  -- Check if the current file is a .qmd file
  if vim.bo.filetype == 'quarto' then
    -- If in a Quarto document (R or Python code), call send_cell
    send_cell()
  elseif vim.bo.filetype == 'r' then
    -- If in a .R file, call send_region (for regions of code)
    send_region()
  else
    print 'Not in a .qmd or .R file. Unable to send code.'
  end
end

-- Send an entire R file to R buffer
local function send_all_code()
  if vim.bo.filetype == 'r' then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd 'normal! ggVG'
    send_region()
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  else
    print 'Not a .R file. Unable to send code.'
  end
end

-- Send one line from an R file
local function send_one_line()
  if vim.bo.filetype == 'r' then
    vim.cmd 'normal! V'
    send_region()
    vim.cmd 'normal! <esc>'
  else
    print 'Not a .R file. Unable to send code.'
  end
end

-- send code maps
vim.keymap.set('', '<leader>rr', send_code, { desc = '[R]un R code chunk' })
vim.keymap.set('', '<leader>ra', send_all_code, { desc = '[R]un R file' })
vim.keymap.set('', '<leader>rl', send_one_line, { desc = '[R]un current line of R code' })

-- send one line and move cursor down
vim.keymap.set('', '<leader>rj', function()
  send_one_line()
  vim.cmd 'normal! j'
end, { desc = '[R]un current line of R code and move cursor down' })

-- Close R terminal
function CloseRTerm()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      -- Get the terminal buffer name
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match ':%d+:R$' or buf_name:match ':R$' then
        -- Send quit() command to R
        vim.api.nvim_chan_send(vim.bo[buf].channel, 'quit()\n')
        -- Close the terminal buffer after a short delay to allow R to exit
        vim.defer_fn(function()
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end, 500) -- Wait 500ms before closing to let R quit cleanly

        return
      end
    end
  end
  print 'No R terminal found'
end

vim.keymap.set('n', '<leader>rq', CloseRTerm, { desc = '[C]lose R terminal', silent = true })
