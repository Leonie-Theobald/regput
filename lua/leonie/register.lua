print("Setup register.lua")

-- actual register window
local function show_registers()
  -- save information on current buffer for later
  local original_win = vim.api.nvim_get_current_win()
  local original_cursor = vim.api.nvim_win_get_cursor(original_win)

  -- Get registers output
  local reg_output = vim.fn.execute("registers")
  local lines = vim.split(reg_output, "\n")

  for i, line in ipairs(lines) do
    local new_line = string.sub(line, 1, 50)
    if vim.fn.strchars(line) > 50 then
      lines[i] = new_line .. "..."
    else 
      lines[i] = new_line
    end
  end

  -- Define window position and size
  local row = 5
  local col = (function() -- col placements depends on whether neo-tree is shown or not
    local neo_win = nil
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "neo-tree" then
        neo_win = win
        break
      end
    end
    
    if neo_win then
     neo_tree_width = vim.api.nvim_win_get_width(neo_win) + 7
    else 
      neo_tree_width = 6
    end

    return neo_tree_width
  end)()
  local width = 55
  local height = 20

  -- Create buffer for preview
  local buf_preview = vim.api.nvim_create_buf(false, true)
  vim.bo[buf_preview].bufhidden = "wipe"
  vim.bo[buf_preview].filetype = "vim"

  -- Open floating window for preview
  local win_preview = vim.api.nvim_open_win(buf_preview, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col + width + 1,
    style = "minimal",
    border = "rounded",
  })

  -- Create buffer for lines
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "vim"

  -- Open floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })
  
  -- modify cursor
  vim.wo[win].cursorline = true	-- highlight active line
  vim.api.nvim_win_set_cursor(win, { 3, 0 }) -- set cursor on first real reg line

  -- callback if cursor moves in this window
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = function()
      local cursor_position = vim.api.nvim_win_get_cursor(win)
      -- force cursor to stay in area with register lines
      if cursor_position[1] < 3 then
        vim.api.nvim_win_set_cursor(win, {3, 0})
      end
    end,
  })

  -- Close mappings
  vim.keymap.set("n", "q", function()
    -- close floating windows
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_win_close(win_preview, true)

    -- go back to original window and cursor position
    vim.api.nvim_set_current_win(original_win)
    vim.api.nvim_win_set_cursor(original_win, original_cursor)
  end, { buffer = buf, nowait = true })
end

-- Key mapping for register function
vim.keymap.set("n", '<leader>"', show_registers, { desc = "Show Registers" })

