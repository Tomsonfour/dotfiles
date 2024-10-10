vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

vim.cmd ':set nowrap'
-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)


-- kitty
-- handle opacity
os.execute 'bash ~/.config/kitty/change_config.sh background_opacity 1.0 reload'
-- handle colors
local normal_hl = vim.api.nvim_get_hl(0, {name = "Normal"})
local bg_color = normal_hl.bg and string.format("#%06x", normal_hl.bg) or "NONE"
os.execute('bash ~/.config/kitty/change_config.sh background "' ..bg_color.. '" reload')

os.execute 'bash ~/.config/kitty/change_config.sh background_opacity 0.0 false'

vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
  callback = function()
    os.execute 'bash ~/.config/kitty/change_config.sh background_opacity 0.0 reload'
  end,
})


-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    print('yanked')
    vim.highlight.on_yank()
  end,
})


local subcommands = require('session_manager.subcommands')

vim.api.nvim_create_user_command('SessionManager', subcommands.run, { nargs = '*', bang = true, complete = subcommands.complete, desc = 'Run session manager command' })

