return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        path_display = { "smart" },
        layout_strategy = "horizontal",
        layout_config = {
          preview_width = 0.65,
          horizontal = {
            size = {
              width = "95%",
              height = "95%",
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
          }
        },
      },
    })

    telescope.load_extension("fzf")
    vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
  end,
}