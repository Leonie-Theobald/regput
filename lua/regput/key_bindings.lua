local key_bindings = {}

function key_bindings.add(win_preview, win_detail, win_original, buf_preview, lines, cursor_original)
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
	end, { buffer = buf_preview, nowait = true })
end

return key_bindings
