local ascii_art = require "ascii"
vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#7AA2F7" })

local config = {
  header = ascii_art.art.text.neovim.sharp,
  week_header = {
    enable = false,
  },
  shortcut = {
    { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
    {
      icon = " ",
      icon_hl = "@variable",
      desc = "Files",
      group = "Label",
      action = "Telescope find_files",
      key = "f",
    },
    {
      desc = " sessions",
      group = "DiagnosticHint",
      action = "SessionManager load_last_session",
      key = "s",
    },
    {
      desc = " dotfiles",
      group = "Number",
      action = "Telescope dotfiles",
      key = "d",
    },
  },
  project = {
    limit = 0,
    enable = true,
    icon = "󰏓 ",
    icon_hl = "DashboardRecentProjectIcon",
    action = "Telescope neovim-project discover",
    label = " Recent Projects:",
  },
}
return config
