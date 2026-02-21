local key_bindings = {}

local register = require ("regput.register")
local window = require ("regput.window")

function key_bindings.add(win_preview, win_detail, win_original, buf_preview, lines, cursor_original)
	-- Paste mappings
	vim.keymap.set("n", "p", function()
		local relevant_register_content = register.get_register_content_at_cursor_position(win_preview, lines)
		window.close_register_window(win_preview, win_detail, win_original, cursor_original)
		window.put_content_to_window(relevant_register_content, win_original, cursor_original, "p")
	end, { buffer = buf_preview, nowait = true })

	vim.keymap.set("n", "P", function()
		local relevant_register_content = register.get_register_content_at_cursor_position(win_preview, lines)
		window.close_register_window(win_preview, win_detail, win_original, cursor_original)
		window.put_content_to_window(relevant_register_content, win_original, cursor_original, "P")
	end, { buffer = buf_preview, nowait = true })

	-- Close mappings
	vim.keymap.set("n", "q", function()
		window.close_register_window(win_preview, win_detail, win_original, cursor_original)
	end, { buffer = buf_preview, nowait = true })
end

return key_bindings
