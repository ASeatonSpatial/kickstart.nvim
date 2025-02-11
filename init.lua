require 'config.global'
require 'config.keymaps'
require 'config.autocmd'
require 'config.lazy' -- see lua/config/lazy.lua for contents page of plugins
require 'plugins.keymaps'

-- MY TODO:
-- 1. Modularise - keybinds.lua, autocmd.lua, quarto.lua and so on.
-- 2. Write my own version of slime calls for quarto support
-- 3. Add support for markdown files.  Knitr nvim plugins?
-- 4. Try the folke/flash plugin for faster navigation? It looks really cool.
-- 5. General git integration plugins.  Or stick with sourcetree? Investigate
-- 6. Check out the oil plugin to edit filesystem in a buffer
-- 7. DONE - Add custom keymap for rendering open quarto file
-- 8. MAJOR PROJECT:  Add support for .tex files
-- 9. Any way to delete sessions from the select list?
-- 10. Move rest of init.lua setup into config = function() sections

-- Quarto setup:
-- 
local quarto = require 'quarto'
quarto.setup()

-- Quarto preview
vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true, desc = 'Quarto preview' })

-- Insert R code chunk on new line below current line
vim.keymap.set('n', '<leader>qc', 'o```{r}<CR>```<esc>O', { desc = '[I]nsert R code chunk' })

-- Quarto render
local function quarto_render()
  -- Check if the current buffer is a .qmd file
  if vim.bo.filetype ~= 'quarto' then
    print 'Not a .qmd file. Unable to run Quarto render.'
    return
  end

  -- Get the full path of the current file
  local current_file = vim.fn.expand '%:p'

  -- Open a new tab with a terminal buffer
  vim.cmd 'tabnew'
  vim.cmd 'terminal'

  vim.defer_fn(function()
    vim.cmd 'startinsert' -- Ensure terminal starts in insert mode
  end, 100)

  -- local term_bufnr = vim.api.nvim_get_current_buf()

  -- Send the `quarto render` command to the terminal
  local render_cmd = 'quarto render ' .. vim.fn.shellescape(current_file) .. '\n'
  vim.fn.chansend(vim.b.terminal_job_id, render_cmd)

  -- Switch back to normal mode for quicker tabbing back to other files
  local function check_render_finished()
    local lines = vim.api.nvim_buf_get_lines(0, -10, -1, false) -- Get last 10 lines
    for _, line in ipairs(lines) do
      if line:match 'Output%s+created:' then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', true)
        return
      end
    end
    -- If not finished, check again in 500ms
    vim.defer_fn(check_render_finished, 500)
  end

  -- Start checking for the output message
  check_render_finished()
end

-- Map to <leader>qr
vim.keymap.set('n', '<leader>qr', quarto_render, { desc = '[Q]uarto [R]ender current .qmd file' })

-- R keybinds
--
-- Open R terminal split
vim.keymap.set('n', '<leader>rs', ':split | terminal R<CR>G<C-w>k', { desc = '[O]pen R terminal' })

-- Autocommand to remove line numbers from terminal windows
vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  pattern = { '*' },
  callback = function(_)
    vim.cmd.setlocal 'nonumber'
    vim.wo.signcolumn = 'no'
  end,
})

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

-- Set up nvim-cmp cmdline
require('cmp').setup {
  sources = {
    { name = 'buffer' },
  },
}

local cmp = require 'cmp'
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' },
      },
    },
  }),
})

require('oil').setup {
  delete_to_trash = false,
  -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
  -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
  -- Additionally, if it is a string that matches "actions.<name>",
  -- it will use the mapping at require("oil.actions").<name>
  -- Set to `false` to remove a keymap
  -- See :help oil-actions for a list of all available actions
  keymaps = {
    ['g?'] = { 'actions.show_help', mode = 'n' },
    ['<CR>'] = 'actions.select',
    ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
    ['<C-h>'] = { 'actions.select', opts = { horizontal = true } },
    ['<C-t>'] = { 'actions.select', opts = { tab = true } },
    ['<C-p>'] = 'actions.preview',
    ['<C-c>'] = { 'actions.close', mode = 'n' },
    ['<C-l>'] = 'actions.refresh',
    ['-'] = { 'actions.parent', mode = 'n' },
    ['_'] = { 'actions.open_cwd', mode = 'n' },
    ['`'] = { 'actions.cd', mode = 'n' },
    ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
    ['gs'] = { 'actions.change_sort', mode = 'n' },
    ['gx'] = 'actions.open_external',
    ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
    ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
  },
  -- Set to false to disable all of the above keymaps
  use_default_keymaps = true,
}

-- Open oil buffer in parent directory
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = '[O]pen parent directory' })

-- mini.sessions keymaps
-- ---------------------

-- Open session from list 
vim.keymap.set('n', '<leader>ms', '<CMD>:lua MiniSessions.select()<CR>', { desc = '[S]elect session from list' })

-- Write session with prompt for input for session name
local function mini_session_write()
  vim.ui.input({ prompt = "Enter session name: " }, function(input)
    if input and input ~= "" then
      MiniSessions.write(input)
    else
      print("Session name cannot be empty!")
    end
  end)
end

vim.keymap.set('n', '<leader>mw', mini_session_write, { desc = '[W]rite session' })

-- Delete session by name
local function mini_session_delete()
  vim.ui.input({ prompt = "Enter session name: " }, function(input)
    if input and input ~= "" then
      MiniSessions.delete(input)
    else
      print("Session name cannot be empty!")
    end
  end)
end
vim.keymap.set('n', '<leader>md', mini_session_delete, { desc = '[D]elete session by name' })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
