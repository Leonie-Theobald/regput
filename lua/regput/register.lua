local register = {}

function register.get_register_content_at_cursor_position(win_preview, register_lines)
	local cursor_position = vim.api.nvim_win_get_cursor(win_preview)
	local relevant_register = register_lines[cursor_position[1]]
	local relevant_register_name = string.sub(
		relevant_register,
		7,	-- extract register name character
		8
	)
	return vim.fn.getreg(relevant_register_name, 1, true)
end

function register.get_current_content()
	local reg_output = vim.fn.execute("registers")
	local register_lines = vim.split(reg_output, "\n")

	for i, line in ipairs(register_lines) do
		local new_line = string.sub(line, 1, 50)
		if vim.fn.strchars(line) > 50 then
			register_lines[i] = new_line .. "..."
		else
			register_lines[i] = new_line
		end
	end

	return register_lines
end

return register
