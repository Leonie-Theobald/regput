local window = {}

function window.close_register_window(win_preview, win_detail, win_original, cursor_original)
	-- close floating windows
	vim.api.nvim_win_close(win_preview, true)
	vim.api.nvim_win_close(win_detail, true)

	-- go back to original window and cursor position
	vim.api.nvim_set_current_win(win_original)
	vim.api.nvim_win_set_cursor(win_original, cursor_original)
end

function window.put_content_to_window(content, target_window, cursor_position, p_or_P)
	vim.api.nvim_set_current_win(target_window)
	vim.api.nvim_win_set_cursor(target_window, cursor_position)
	if p_or_P == "p" then
		vim.api.nvim_put(content, "l", true, true)
	elseif p_or_P == "P" then
		vim.api.nvim_put(content, "l", false, true)
	else
		error("Select p or P")
	end
end

function window.get_neo_tree_width()
	local neo_win = nil
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "neo-tree" then
			neo_win = win
			break
		end
	end

	if neo_win then
		return vim.api.nvim_win_get_width(neo_win) + 1
	else
		return 0
	end
end

return window
