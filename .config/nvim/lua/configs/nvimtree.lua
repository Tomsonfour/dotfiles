local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set('n', '<leader>k', api.tree.change_root_to_parent, opts('Up'))
  vim.keymap.set('n', '<leader>j', api.tree.change_root_to_node, opts('Down'))
  vim.keymap.set('n', '<leader>?',     api.tree.toggle_help, opts('Help'))
  vim.keymap.set('n', '<leader>d', api.tree.toggle_hidden_filter, opts('toggle dotfiles'))
  vim.keymap.set('n', '<C-CR>', api.node.open.vertical, opts('open in new vertical'))
end

local options = {
  on_attach = my_on_attach,
  filters = { dotfiles = true },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = 30,
    preserve_window_proportions = true,
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = { unmerged = "" },
      },
    },
  },
}
return options
