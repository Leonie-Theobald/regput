local regput_modul = {}

local function get_neo_tree_width()  -- col placements depends on whether neo-tree is shown or not
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
end

local function get_register_content_at_cursor_position(win_preview, register_lines)
	local cursor_position = vim.api.nvim_win_get_cursor(win_preview)
	local relevant_register = register_lines[cursor_position[1]]
	local relevant_register_name = string.sub(
		relevant_register, 
		7,	-- extract register name character
		8
	)
	return vim.fn.getreg(relevant_register_name, 1, true)	
end

local function close_register_view(win_preview, win_detail, win_original, cursor_original)
	-- close floating windows
	vim.api.nvim_win_close(win_preview, true)
	vim.api.nvim_win_close(win_detail, true)

	-- go back to original window and cursor position
	vim.api.nvim_set_current_win(win_original)
	vim.api.nvim_win_set_cursor(win_original, cursor_original)
end

local function put_content_to_window(content, window, cursor_position, p_or_P)
	vim.api.nvim_set_current_win(window)
	vim.api.nvim_win_set_cursor(window, cursor_position)
	if p_or_P == "p" then
		vim.api.nvim_put(content, "l", true, true)
	elseif p_or_P == "P" then
		vim.api.nvim_put(content, "l", false, true)
	else 
		error("Select p or P")
	end
end

-- actual register window
function regput_modul.start()
	-- save information on current buffer for later
	local win_original = vim.api.nvim_get_current_win()
	local cursor_original = vim.api.nvim_win_get_cursor(win_original)

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

	-- Define preview window size and position
	local preview_width = 55
	local preview_height = 20
	local preview_row = 5
	local preview_col = get_neo_tree_width()

	-- Create buffer for preview
	local buf_preview = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_preview, 0, -1, false, lines)
	vim.bo[buf_preview].bufhidden = "wipe"
	vim.bo[buf_preview].filetype = "vim"

	-- Open floating window for preview
	local win_preview = vim.api.nvim_open_win(buf_preview, true, {
		relative = "editor",
		width = preview_width,
		height = preview_height,
		row = preview_row,
		col = preview_col,
		style = "minimal",
		border = "rounded",
	})

	-- Create buffer for detailed view
	local buf_detail = vim.api.nvim_create_buf(false, true)
	vim.bo[buf_detail].bufhidden = "wipe"
	vim.bo[buf_detail].filetype = "vim"

	-- Open floating window for detailed view
	local win_detail = vim.api.nvim_open_win(buf_detail, false, {
		relative = "editor",
		-- take remaining space of the whole nvim view left by neo-tree and the preview win
		width = vim.o.columns - get_neo_tree_width() - preview_width - 4,
		height = preview_height,
		row = preview_row,
		col = preview_col + preview_width + 1, -- placed right of preview window
		style = "minimal",
		border = "rounded",
	})

	-- modify cursor
	vim.wo[win_preview].cursorline = true	-- highlight active line
	vim.api.nvim_win_set_cursor(win_preview, { 3, 0 }) -- set cursor on first real reg line
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = buf_preview,
		callback = function()
			local cursor_position = vim.api.nvim_win_get_cursor(win_preview)
			-- force cursor to stay in area with register lines
			if cursor_position[1] < 3 then
				cursor_position[1] = 3
				vim.api.nvim_win_set_cursor(win_preview, cursor_position)
			end

			vim.api.nvim_buf_set_lines(buf_detail, 0, -1, true, {}) -- clears detail buf
			local relevant_register_content = get_register_content_at_cursor_position(win_preview, lines)
			put_content_to_window(relevant_register_content, win_detail, {1, 1}, "P")

			-- make preview window active again
			vim.api.nvim_set_current_win(win_preview)

		end,
	})

	-- Paste mappings
	vim.keymap.set("n", "p", function()
		local relevant_register_content = get_register_content_at_cursor_position(win_preview, lines)
		close_register_view(win_preview, win_detail, win_original, cursor_original)
		put_content_to_window(relevant_register_content, win_original, cursor_original, "p")
	end, { buffer = buf_preview, nowait = true })

	vim.keymap.set("n", "P", function()
		local relevant_register_content = get_register_content_at_cursor_position(win_preview, lines)
		close_register_view(win_preview, win_detail, win_original, cursor_original)
		put_content_to_window(relevant_register_content, win_original, cursor_original, "P")
	end, { buffer = buf_preview, nowait = true })

	-- Close mappings
	vim.keymap.set("n", "q", function()
		close_register_view(win_preview, win_detail, win_original, cursor_original)
	end, { buffer = buf, nowait = true })

end

function regput_modul.setup(opts)
	vim.api.nvim_create_user_command("StartRegput", regput_modul.start, {})
	vim.api.nvim_create_user_command("TestRegput", function()
		print("Regput executed")
	end, {})
	-- Key mapping for register function
	vim.keymap.set(
		"n",
		'<leader>"',
		regput_modul.start,
		{ desc = "Open register view", silent = true}
	)
end

return regput_modul
