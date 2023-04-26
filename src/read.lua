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

local function match_to_token(class, match)
  if class == "whitespace" or class == "comment" then
    -- Skip
  elseif class == "number" then
    return { class = class, literal = tonumber(match) }
  elseif class == "boolean" then
    return { class = class, literal = match == "true" }
  elseif class == "string" then
    return { class = class, literal = match:sub(2, -2) }
  elseif class == "keyword" then
    return { class = class, literal = match:sub(2) }
  elseif class == "symbol" then
    return { class = class, literal = match }
  elseif class == "parenstart" or class == "parenend" then
    return { class = class }
  elseif class == "nil" then
    return { class = class }
  else
    error("unknown class: " .. class)
  end
end

local function tokenize(source)
  local index = 1

  local function attempt_match()
    for _, rule in ipairs(token_rules) do
      local class, pattern = table.unpack(rule)

      local match = source:match(pattern, index)
      if match then
        local token = match_to_token(class, match)

        if token then
          coroutine.yield(token)
        end

        index = index + match:len()

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
  return parse_expression(token, next_token)
end
