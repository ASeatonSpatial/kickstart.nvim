return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Comment out lines
      require('mini.comment').setup()

      -- Icons required for which-key
      require('mini.icons').setup()

      -- Session manager
      -- ---------------
      require('mini.sessions').setup()

      -- Session keymaps:
      -- Open session from list
      vim.keymap.set('n', '<leader>ms', '<CMD>:lua MiniSessions.select()<CR>', { desc = '[S]elect session from list' })

      -- Write session with prompt for input for session name
      local function mini_session_write()
        vim.ui.input({ prompt = 'Enter session name: ' }, function(input)
          if input and input ~= '' then
            MiniSessions.write(input)
          else
            print 'Session name cannot be empty!'
          end
        end)
      end

      vim.keymap.set('n', '<leader>mw', mini_session_write, { desc = '[W]rite session' })

      -- Delete session by name
      local function mini_session_delete()
        vim.ui.input({ prompt = 'Enter session name: ' }, function(input)
          if input and input ~= '' then
            MiniSessions.delete(input)
          else
            print 'Session name cannot be empty!'
          end
        end)
      end
      vim.keymap.set('n', '<leader>md', mini_session_delete, { desc = '[D]elete session by name' })
    end,
  },
}
