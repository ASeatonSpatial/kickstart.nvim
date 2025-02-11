require 'config.global'
require 'config.keymaps'
require 'config.autocmd'
require 'config.lazy' -- see lua/config/lazy.lua for contents page of plugins
require 'config.R' -- Contains slim setup, must load after config.lazy

-- TODO:
-- 1. DONE: Modularise - keybinds.lua, autocmd.lua, quarto.lua and so on.
-- 2. Write my own version of slime calls for quarto support
-- 3. Add support for markdown files.  Knitr nvim plugins?
-- 4. Try the folke/flash plugin for faster navigation? It looks really cool.
-- 5. General git integration plugins.  Or stick with sourcetree? Investigate
-- 6. DONE -Check out the oil plugin to edit filesystem in a buffer
-- 7. DONE - Add custom keymap for rendering open quarto file
-- 8. MAJOR PROJECT:  Add support for .tex files
-- 9. Any way to delete sessions from the select list?
-- 10. DONE: Move rest of init.lua setup into config = function() sections
-- 11. Quarto and R setup:
--     a) Move to quarto config = function()?
--     b) Separate R support from Quarto support? - moved to lua/config/R.lua
--     c) Write separate plugin for slime stuff?
-- 12. Test this config on windows.

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
