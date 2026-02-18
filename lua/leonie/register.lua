print("Setup register.lua")

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

	-- Define preview window size and position
	local width = 55
	local height = 20
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

	-- Create buffer for preview
	local buf_preview = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf_preview, 0, -1, false, lines)
	vim.bo[buf_preview].bufhidden = "wipe"
	vim.bo[buf_preview].filetype = "vim"

	-- Open floating window for preview
	local win_preview = vim.api.nvim_open_win(buf_preview, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
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
		width = width,
		height = height,
		row = row,
		col = col + width + 1, -- placed right of preview window
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
			end

			-- clear detailed window and paste the content of the currently selected
			-- register in the preview window
			vim.api.nvim_buf_set_lines(buf_detail, 0, -1, true, {}) -- clears detail buf
			local relevant_register = lines[cursor_position[1]]
			local relevant_register_name = string.sub(
				relevant_register, 
				7,	-- extract register name character
				8
			)
			local relevant_register_content = vim.fn.getreg(relevant_register_name, 1, true)	
			-- paste register content into detailed window
			put_content_to_window(relevant_register_content, win_detail, {1, 1}, "P")

			-- make preview window active again
			vim.api.nvim_set_current_win(win_preview)

		end,
	})

	-- Close mappings
	vim.keymap.set("n", "q", function()
		-- close floating windows
		vim.api.nvim_win_close(win_preview, true)
		vim.api.nvim_win_close(win_detail, true)

		-- go back to original window and cursor position
		vim.api.nvim_set_current_win(original_win)
		vim.api.nvim_win_set_cursor(original_win, original_cursor)
	end, { buffer = buf, nowait = true })
end

-- Key mapping for register function
vim.keymap.set("n", '<leader>"', show_registers, { desc = "Show Registers" })

