return {
  'dart-lang/dart-vim-plugin',
  config = function()
    vim.g.dart_style_guide = 2
    vim.g.dart_format_on_save = 1
    vim.g.dart_trailing_comma_indent = true
  end,
}
