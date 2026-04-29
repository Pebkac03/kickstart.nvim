return {
  'olimorris/codecompanion.nvim',
  dependenices = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  opts = {
    interactions = {
      chat = { adapter = 'opencode', model = '' },
      inline = { adapter = 'opencode', model = '' },
      background = { adapter = 'opencode', model = '' },
      cli = { adapter = 'opencode', model = '' },
      cmd = { adapter = 'opencode', model = '' },
    },
    opts = { log_level = 'DEBUG' },
  },
}
