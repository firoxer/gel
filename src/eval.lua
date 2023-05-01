local qol = require("src.qol")
local predefined = require("src.predefined")

local function resolve(env, symbol)
  if env[symbol] then
    return env[symbol]
  elseif env["&parent"] then
    return resolve(env["&parent"], symbol)
  else
    error("could not resolve symbol: " .. symbol)
  end
end

local eval = nil -- Forward declaration

local specials = {
  ["do"] = function(env, node)
    local body_forms = slice(node.elements, 2)

    local last_result = nil
    for _, form in ipairs(body_forms) do
      last_result = eval(env, form)
    end
    return last_result
  end,

  fn = function(env, node)
    local params = node.elements[2]
    assert(params, "fn has no parameters or body")
    assert(params.class == "list", "parameters should be a list")

    local body_forms = slice(node.elements, 3)
    assert(#body_forms > 0, "fn has no body")

    local do_body = {
      class = "list",
      elements = concat(
        { { class = "symbol", literal = "do" } },
        body_forms
      )
    }
    
    return {
      class = "fn",
      params = params,
      body = do_body,
      _line_number = node._line_number,
      _col_number = node._col_number,
    }
  end,

  ["if"] = function(env, node)
    local condition = node.elements[2]
    local true_branch = node.elements[3]
    local false_branch = node.elements[4]

    if eval(env, condition) then
      return eval(env, true_branch)
    else
      return eval(env, false_branch)
    end
  end,

  let = function(env, node)
    assert(#node.elements == 3, "let should have bindings and body")
    local bindings_list = node.elements[2]
    local body = node.elements[3]

    assert(bindings_list.class == "list")
    assert(#bindings_list.elements % 2 == 0)

    local new_env = { ["&parent"] = env }
    for i = 1, #bindings_list.elements, 2 do
      local symbol = bindings_list.elements[i].literal
      local value = eval(new_env, bindings_list.elements[i + 1])

      new_env[symbol] = value
    end

    return eval(new_env, body)
  end,
}

local function call(env, node)
  local fn_symbol = node.elements[1]

  if predefined[fn_symbol.literal] then
    local args = {}
    for _, arg in slice(node.elements, 2) do
      if arg.class == "symbol" then
        table.insert(args, resolve(env, arg.literal))
      else
        table.insert(args, arg.literal)
      end
    end

    return predefined[fn_symbol.literal](table.unpack(args))
  else
    local args = slice(node.elements, 2)

    local fn = resolve(env, fn_symbol.literal)    

    if #args ~= #fn.params.elements then
      error("wrong number of arguments (got " .. #args .. ", want " .. #fn.params.elements .. ")")
    end

    local fn_env = { ["&parent"] = env }
    for i, param in ipairs(fn.params.elements) do
      fn_env[param.literal] = eval(env, args[i])
    end

    return eval(fn_env, fn.body)
  end
end

eval = function(env, node)
  assert(type(env) == "table")
  assert(node ~= nil)

  if type(node) ~= "table" then -- Hmm
    return node
  end

  if node.class == "list" then
    assert(#node.elements > 0, "empty list")
    local head = node.elements[1]
    assert(head.class == "symbol", "non-symbol initial element")

    if specials[head.literal] then
      return specials[head.literal](env, node)
    else
      return call(env, node)
    end
  elseif node.class == "symbol" then
    return resolve(env, node.literal)
  elseif node.class == "number" then
    return node.literal
  elseif node.class == "string" then
    return node.literal
  elseif node.class == "boolean" then
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
