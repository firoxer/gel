local qol = require("src.qol")

local symbol_char = "%*%-%?%+%%!<>=a-zA-Z0-9"

local token_rules = {
  { "comment", "^(;[^\n]*[\n])" },
  { "string",  "^(\"\")" },
  { "string", "^(\".-[^\\]\")" },
  { "keyword", "^(:[" .. symbol_char .. "]+)" },
  { "number",  "^(%-?%d+%.?%d*)" },
  { "nil", "^(nil)[^" .. symbol_char .. "]" },
  { "boolean", "^(true)[^" .. symbol_char .. "]" },
  { "boolean", "^(false)[^" .. symbol_char .. "]" },
  { "symbol", "^([" .. symbol_char .. "]+)" },
  { "parenstart", "^([%(])" },
  { "parenend", "^([%)])" },
  { "whitespace", "^([ \n\t]+)" }
}

local function match_to_literal(class, match)
  if class == "number" then
    return tonumber(match)
  elseif class == "boolean" then
    return match == "true"
  elseif class == "string" then
    return match:sub(2, -2)
  elseif class == "keyword" then
    return match:sub(2)
  elseif class == "symbol" then
    return match
  elseif class == "parenstart" or class == "parenend" then
    return nil
  elseif class == "nil" then
    return nil
  else
    error("unknown class: " .. class)
  end
end

local function tokenize(source)
  local index = 1
  local line_number = 1
  local col_number = 1

  local function attempt_match()
    for _, rule in ipairs(token_rules) do
      local class, pattern = table.unpack(rule)

      local match = source:match(pattern, index)
      if match then
        index = index + match:len()

        local newlines = #collect(match:gmatch("\n"))
        line_number = line_number + newlines
        col_number = newlines > 0 and 1 or (col_number + match:len())

        if class ~= "whitespace" and class ~= "comment" then
          local token = {
            class = class,
            literal = match_to_literal(class, match),
            line_number = line_number,
            col_number = col_number,
          }

          coroutine.yield(token)
        end

        return
      end
    end

    -- No matches?
    error("unexpected char at pos " .. index .. ": " .. (source:sub(index, index)))
  end

  while index <= source:len() do
    attempt_match()
  end
end

local parse_expression = nil -- Forward declaration

local function parse_list(token, next_token)
  if not token then
    error("unexpected eof")
  end

  local elements = {}

  while token.class ~= "parenend" do
    table.insert(elements, parse_expression(token, next_token))
    token = next_token()
  end

  return { class = "list", elements = elements }
end

parse_expression = function(token, next_token)
  if not token then
    error("unexpected eof")
  end

  if token.class == "parenstart" then
    return parse_list(next_token(), next_token)
  else
    return token -- It's an atom and it's good as it is
  end
end

return function(source)
  local next_token = coroutine.wrap(function()
    tokenize(source)
  end)

  local token = next_token()
  local expr = parse_expression(token, next_token)

  local unexpected_token = next_token()
  if unexpected_token then
    qol.display_token(source, unexpected_token)
    error("unexpected further source after end of first expression")
  end

  return expr
end
