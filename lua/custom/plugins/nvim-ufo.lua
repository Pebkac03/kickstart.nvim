vim.pack.add {'https://github.com/kevinhwang91/promise-async'}
vim.pack.add { 'https://github.com/kevinhwang91/nvim-ufo' }
require('ufo').setup {

	provider_selector = function(bufnr, filetype, buftype)
		if buftype == 'acwrite' then
			return 'indent'
		elseif filetype == 'dart' then
			return { 'treesitter', 'indent' }
		else
			return { 'lsp', 'indent' }
		end
	end,
}

vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
