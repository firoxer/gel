prettyprint = nil -- Forward declaration

local function indent(depth)
  io.stderr:write(("  "):rep(depth))
end

local prettyprinters = {
  ["table"] = function(x, depth)
    io.stderr:write("{\n")
    if x[1] ~= nil then
      for _, v in ipairs(x) do
        indent(depth)
        prettyprint(v, depth + 1)
        io.stderr:write(",\n")
      end
    else
      for k, v in pairs(x) do
        indent(depth)
        io.stderr:write(tostring(k))
        io.stderr:write(" = ")
        prettyprint(v, depth + 1)
        io.stderr:write(",\n")
      end
    end
    indent(depth - 1)
    io.stderr:write("}")
  end,

  ["nil"] = function(x)
    io.stderr:write("nil")
  end,

  ["string"] = function(x)
    local nicer_x = x:gsub("\n", "\\n"):gsub("\t", "\\t")
    io.stderr:write("\"", nicer_x, "\"")
  end,

  ["number"] = function(x)
    io.stderr:write(x)
  end,

  ["boolean"] = function(x)
    io.stderr:write(tostring(x))
  end
}

function prettyprint(x, depth)
  local printer = prettyprinters[type(x)]

  if not printer then
    error("unknown type: " .. type(x))
  end

  printer(x, depth)
  io.stderr:write("\n")
end

function trace(x)
  local debug_info = debug.getinfo(2)
  io.stderr:write(debug_info.short_src, ":", debug_info.currentline, ": ")

  prettyprint(x, 1)
  io.stderr:write("\n")
end

function collect(coro)
  local tbl = {}

  for v in coro do
    table.insert(tbl, v)
  end

  return tbl
end

function merge(tbl1, tbl2)
  local tbl3 = {}

  for k, v in pairs(tbl1) do
    tbl3[k] = v
  end
  for k, v in pairs(tbl2) do
    tbl3[k] = v
  end

  return tbl3
end

function shallowcopy(tbl)
  local new = {}
  for k, v in pairs(tbl) do
    new[k] = tbl[k]
  end
  return new
end

function slice(tbl, from, to)
  if to == nil then
    to = #tbl
  end
  
  local sliced = {}
  for i = from, to do
    table.insert(sliced, tbl[i])
  end
  return sliced
end
