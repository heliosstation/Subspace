-- catppuccin
  -- See: https://github.com/catppuccin/nvim
return {
  "catppuccin/nvim",
  lazy = false,
  name = "catppuccin",
  priority = 1000,
  opts = function(_, opts)
    opts.flavour = "mocha" -- latte, frappe, macchiato, mocha
    opts.transparent_background = true -- setting the background color.
    opts.integrations = {
      telescope = true,
    }
  end,
  specs = {
    -- Add custom specs
  },
  config = function()
    vim.cmd.colorscheme("catppuccin")
  end,
}