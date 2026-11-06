vim.pack.add { 'https://github.com/olimorris/codecompanion.nvim' }
require('codecompanion').setup({

	interactions = {
		chat = { adapter = 'opencode', model = '' },
		inline = { adapter = 'opencode', model = '' },
		background = { adapter = 'opencode', model = '' },
		cli = { adapter = 'opencode', model = '' },
		cmd = { adapter = 'opencode', model = '' },
	},
	opts = { log_level = 'DEBUG' },
})
