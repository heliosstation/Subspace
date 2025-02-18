-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Auto format
vim.g.autoformat = true

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

vim.cmd("let g:netrw_liststyle = 3")

-- Set highlight on search
vim.opt.hlsearch = true
-- Enable auto write
vim.opt.autowrite = true 
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
-- Sync with system clipboard
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" 
vim.opt.completeopt = "menu,menuone,noselect"
-- Hide * markup for bold and italic, but not markers with substitutions
vim.opt.conceallevel = 2 
-- Confirm to save changes before exiting modified buffer
vim.opt.confirm = true 
-- Enable highlighting of the current line
vim.opt.cursorline = true 
-- Use spaces instead of tabs
vim.opt.expandtab = true 
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vim.opt.foldlevel = 99
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
-- Ignore case
vim.opt.ignorecase = true 
-- preview incremental substitute
vim.opt.inccommand = "nosplit"
vim.opt.jumpoptions = "view"
-- global statusline
vim.opt.laststatus = 3 
-- Wrap lines at convenient points
vim.opt.linebreak = true 
-- Show some invisible characters (tabs...)
vim.opt.list = true 
-- Enable mouse mode
vim.opt.mouse = "a" 
-- Print line number
vim.opt.number = true 
-- Popup blend
vim.opt.pumblend = 10 
-- Maximum number of entries in a popup
vim.opt.pumheight = 10 
-- Relative line numbers
vim.opt.relativenumber = true 
-- Disable the default ruler
vim.opt.ruler = false 
-- Lines of context
vim.opt.scrolloff = 4 
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
-- Round indent
vim.opt.shiftround = true 
-- Size of an indent
vim.opt.shiftwidth = 2 
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
-- Dont show mode since we have a statusline
vim.opt.showmode = false
-- Columns of context
vim.opt.sidescrolloff = 8 
-- Always show the signcolumn, otherwise it would shift the text each time
vim.opt.signcolumn = "yes" 
-- Don"t ignore case with capitals
vim.opt.smartcase = true 
-- Insert indents automatically
vim.opt.smartindent = true
vim.opt.spelllang = { "en" }
-- Put new windows below current
vim.opt.splitbelow = true 
vim.opt.splitkeep = "screen"
-- Put new windows right of current
vim.opt.splitright = true 
-- Number of spaces tabs count for
vim.opt.tabstop = 2 
-- True color support
vim.opt.termguicolors = true 
-- Lower than default (1000) to quickly trigger which-key
vim.opt.timeoutlen = vim.g.vscode and 1000 or 300 
vim.opt.undofile = true
vim.opt.undolevels = 10000
-- Save swap file and trigger CursorHold
vim.opt.updatetime = 200 
-- Allow cursor to move where there is no text in visual block mode
vim.opt.virtualedit = "block"
-- Command-line completion mode
vim.opt.wildmode = "longest:full,full" 
-- Minimum window width
vim.opt.winminwidth = 5 
-- Disable line wrap
vim.opt.wrap = false 
vim.opt.smoothscroll = true

