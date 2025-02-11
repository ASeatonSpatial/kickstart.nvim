return {

  { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
    -- for complete functionality (language features)
    'quarto-dev/quarto-nvim',
    ft = { 'quarto' },
    dev = false,
    opts = {},
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua and
      -- added as a nvim-cmp source in lua/plugins/completion.lua
      'jmbuhr/otter.nvim',
    },
    config = function()
      local quarto = require 'quarto'
      quarto.setup()

      -- Quarto preview keymap
      vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true, desc = 'Quarto preview' })

      -- Insert R code chunk on new line below current line
      vim.keymap.set('n', '<leader>qc', 'o```{r}<CR>```<esc>O', { desc = '[I]nsert R code chunk' })

      -- Quarto render keymap
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
    end,
  },
  -- { -- directly open ipynb files as quarto docuements
  --   -- and convert back behind the scenes
  --   'GCBallesteros/jupytext.nvim',
  --   opts = {
  --     custom_language_formatting = {
  --       python = {
  --         extension = 'qmd',
  --         style = 'quarto',
  --         force_ft = 'quarto',
  --       },
  --       r = {
  --         extension = 'qmd',
  --         style = 'quarto',
  --         force_ft = 'quarto',
  --       },
  --     },
  --   },
  -- },

  { -- send code from python/r/qmd documets to a terminal or REPL
    -- like ipython, R, bash
    'jpalardy/vim-slime',
    dev = false,
    init = function()
      vim.b['quarto_is_python_chunk'] = false
      Quarto_is_in_python_chunk = function()
        require('otter.tools.functions').is_otter_language_context 'python'
      end

      vim.cmd [[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]]

      vim.g.slime_target = 'neovim'
      vim.g.slime_no_mappings = true
      vim.g.slime_python_ipython = 1
    end,
    config = function()
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = true

      local function mark_terminal()
        local job_id = vim.b.terminal_job_id
        vim.print('job_id: ' .. job_id)
      end

      local function set_terminal()
        vim.fn.call('slime#config', {})
      end
      vim.keymap.set('n', '<leader>cm', mark_terminal, { desc = '[m]ark terminal' })
      vim.keymap.set('n', '<leader>cs', set_terminal, { desc = '[s]et terminal' })
    end,
  },

  -- { -- paste an image from the clipboard or drag-and-drop
  --   'HakonHarnes/img-clip.nvim',
  --   event = 'BufEnter',
  --   ft = { 'markdown', 'quarto', 'latex' },
  --   opts = {
  --     default = {
  --       dir_path = 'img',
  --     },
  --     filetypes = {
  --       markdown = {
  --         url_encode_path = true,
  --         template = '![$CURSOR]($FILE_PATH)',
  --         drag_and_drop = {
  --           download_images = false,
  --         },
  --       },
  --       quarto = {
  --         url_encode_path = true,
  --         template = '![$CURSOR]($FILE_PATH)',
  --         drag_and_drop = {
  --           download_images = false,
  --         },
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require('img-clip').setup(opts)
  --     vim.keymap.set('n', '<leader>ii', ':PasteImage<cr>', { desc = 'insert [i]mage from clipboard' })
  --   end,
  -- },

  { -- preview equations
    'jbyuki/nabla.nvim',
    keys = {
      { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'toggle inline [m]ath equations' },
      { '<leader>qe', ':lua require("nabla").popup()<CR>', desc = 'toggle [m]ath preview' },
    },
  },

  --   {
  --     'benlubas/molten-nvim',
  --     enabled = false,
  --     build = ':UpdateRemotePlugins',
  --     init = function()
  --       vim.g.molten_image_provider = 'image.nvim'
  --       vim.g.molten_output_win_max_height = 20
  --       vim.g.molten_auto_open_output = false
  --     end,
  --     keys = {
  --       { '<leader>mi', ':MoltenInit<cr>', desc = '[m]olten [i]nit' },
  --       {
  --         '<leader>mv',
  --         ':<C-u>MoltenEvaluateVisual<cr>',
  --         mode = 'v',
  --         desc = 'molten eval visual',
  --       },
  --       { '<leader>mr', ':MoltenReevaluateCell<cr>', desc = 'molten re-eval cell' },
  --     },
  --   },
  --
  --
  --  Autoformat code chunks
  {
    'stevearc/conform.nvim',
    enabled = true,
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat code',
      },
    },
    config = function()
      require('conform').setup {
        notify_on_error = false,
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          lua = { 'mystylua' },
          python = { 'isort', 'black' },
          quarto = { 'injected' },
          r = { 'styler' },
        },
        formatters = {
          mystylua = {
            command = 'stylua',
            args = { '--indent-type', 'Spaces', '--indent-width', '2', '-' },
          },
        },
      }
      -- Customize the "injected" formatter
      require('conform').formatters.injected = {
        -- Set the options field
        options = {
          -- Set to true to ignore errors
          ignore_errors = false,
          -- Map of treesitter language to file extension
          -- A temporary file name with this extension will be generated during formatting
          -- because some formatters care about the filename.
          lang_to_ext = {
            bash = 'sh',
            c_sharp = 'cs',
            elixir = 'exs',
            javascript = 'js',
            julia = 'jl',
            latex = 'tex',
            markdown = 'md',
            python = 'py',
            ruby = 'rb',
            rust = 'rs',
            teal = 'tl',
            r = 'r',
            typescript = 'ts',
          },
          -- Map of treesitter language to formatters to use
          -- (defaults to the value from formatters_by_ft)
          lang_to_formatters = {},
        },
      }
    end,
  },
}
