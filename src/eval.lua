local qol = require("src.qol")
local predefined = require("src.predefined")

local eval = nil -- Forward declaration

local specials = {
  let = function(env, node)
    assert(#node.elements == 3, "let should have bindings and body")
    local bindings_list = node.elements[2]
    local body = node.elements[3]

    assert(bindings_list.class == "list")
    assert(#bindings_list.elements % 2 == 0)

    local new_env = { ["&parent"] = env }
    for i = 1, #bindings_list.elements, 2 do
      local symbol = bindings_list.elements[i].literal
      local value = bindings_list.elements[i + 1].literal

      new_env[symbol] = value
    end

    return eval(new_env, body)
  end
}

local function fn(env, node)
  error("todo")
end

local function call(env, node)
  local fn = node.elements[1]
  local args = slice(node.elements, 2)

  if predefined[fn.literal] then
    return predefined[fn.literal](table.unpack(args))
  else
    error("todo")
  end
end

local function resolve(env, symbol)
  if env[symbol] then
    return env[symbol]
  elseif env["&parent"] then
    return resolve(env["&parent"], symbol)
  else
    error("could not resolve symbol: " .. symbol)
  end
end

eval = function(env, node)
  if node.class == "list" then
    assert(#node.elements > 0, "empty list")
    local head = node.elements[1]
    assert(head.class == "symbol", "non-symbol initial element")

    if specials[head.literal] then
      return specials[head.literal](env, node)
    else
      for i = 2, #node.elements do
        node.elements[i] = eval(env, node.elements[i])
      end

      return call(env, node)
    end
  elseif node.class == "symbol" then
    return resolve(env, node.literal)
  elseif node.class == "number" then
    return node.literal
  else
    qol.display_token(node)    
    error("unknown node class: " .. node.class)
  end
end

return function(node)
  local env = {}
  return eval(env, node)
end
