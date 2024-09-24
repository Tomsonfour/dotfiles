require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")


map("v", "<leader>tc", "gc", { desc = "Toggle comment", remap = true })
map("n", "<leader>tc", "gc", { desc = "Toggle comment", remap = true })

map("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })

require('which-key').add{
    {"<leader>pd", "<cmd>Telescope neovim-project discover<CR>",  desc = "[p]roject [m]anager" , icon = ''}
}
