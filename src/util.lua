tr_inner = nil -- Forward declaration

local function indent(depth)
  io.stderr:write(("  "):rep(depth))
end

local printers = {
  ["table"] = function(x, depth)
    io.stderr:write("{\n")
    if x[1] ~= nil then
      for _, v in ipairs(x) do
        indent(depth)
        tr_inner(v, depth + 1)
        io.stderr:write(",\n")
      end
    else
      for k, v in pairs(x) do
        indent(depth)
        io.stderr:write(tostring(k))
        io.stderr:write(" = ")
        tr_inner(v, depth + 1)
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

function tr_inner(x, depth)
  local printer = printers[type(x)]

  if not printer then
    error("unknown type: " .. type(x))
  end

  printer(x, depth)
end

function tr(x) -- trace
  local debug_info = debug.getinfo(2)
  io.stderr:write(debug_info.short_src, ":", debug_info.currentline, ": ")

  tr_inner(x, 1)
  io.stderr:write("\n")
end

function collect(coro)
  local tbl = {}

  for v in coro do
    table.insert(tbl, v)
  end

  return tbl
end
