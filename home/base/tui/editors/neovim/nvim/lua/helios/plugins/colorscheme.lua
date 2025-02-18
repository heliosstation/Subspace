-- catppuccin
-- See: https://github.com/catppuccin/nvim
return {
  'catppuccin/nvim',
  lazy = false,
  name = 'catppuccin',
  priority = 1000,

  config = function()
    -- https://github.com/catppuccin/nvim?tab=readme-ov-file#configuration
    require('catppuccin').setup({
      flavour = 'mocha',
      transparent_background = true,
      integrations = {
          -- Add plugin integrations: https://github.com/catppuccin/nvim?tab=readme-ov-file#integrations
      },
    })

    vim.cmd.colorscheme('catppuccin')
  end
}