local source = nil

local function set_source(src)
  source = src
end

local function display_token(token)
  local line_number = 1
  local full_line = ""
  tr(token)

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
  set_source = set_source,
  source = source,
}
