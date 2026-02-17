print("Setup register.lua")

-- calculate position to be directly right of (closed) neo-tree
local function get_neo_tree_plus_separation_width()
  local neo_win = nil
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      neo_win = win
      break
    end
  end
  
  -- default is 0
  if neo_win then
   neo_tree_width = vim.api.nvim_win_get_width(neo_win) + 7
  else 
    neo_tree_width = 6
  end

  return neo_tree_width
end

-- callback for cursor moved
local function on_cursor_moved()
  -- force cursor to stay in area with register lines
  local cursor_position = vim.api.nvim_win_get_cursor(win)
  if cursor_position[1] < 3 then
    vim.api.nvim_win_set_cursor(win, {3, 0})
  end
end

-- actual register window
local function show_registers()
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

  -- Create buffer for lines
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "vim"

  -- Define window position and size
  local row = 5
  local col = get_neo_tree_plus_separation_width()
  local width = 60
  local height = 20

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
    callback = on_cursor_moved,
  })

  -- Close mappings
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true })
end

-- Key mapping for register function
vim.keymap.set("n", '<leader>"', show_registers, { desc = "Show Registers" })

