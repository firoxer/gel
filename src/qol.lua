local function display_token(source, token)
  local line_number = 1
  local full_line = nil

  for line in source:gmatch("([^\n]+)\n") do
    if token.line_number == line_number then
      full_line = line
      break
    end
    line_number = line_number + 1
  end

  io.stderr:write(full_line, "\n")
  io.stderr:write(("-"):rep(token.col_number - 1), "^\n")
end

return {
  display_token = display_token,
}
