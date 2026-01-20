function replaceInSelection(batch_size)
  local _, start_line, _, _ = unpack(vim.fn.getpos "'<")
  local _, end_line, _, _ = unpack(vim.fn.getpos "'>")
  start_line = start_line - 1

  local ns = vim.api.nvim_create_namespace 'batch_replace_ns'
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)

  -- Enter string to search for
  local find_word = vim.fn.input 'Find: '
  if find_word == '' then
    return
  end
  local pattern = vim.pesc(find_word)

  batch_size = batch_size or 1

  for i = 0, #lines, batch_size do
    local matches = {}
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

    -- TODO: change for loop to while loop and keep track of occurences found
    for j = 0, batch_size, 1 do
      local s, e = lines[i + j]:find(pattern)
      table.insert(matches, { i + j, i + j, s, e })
      vim.api.nvim_buf_set_extmark(0, ns, i + j, s, {
        end_col = e,
        hl_group = 'Search',
      })
    end
    vim.api.nvim_win_set_cursor(0, { matches[1][1], matches[1][3] })
    -- TODO: To be continued...
  end
end
