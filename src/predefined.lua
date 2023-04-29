local function plus(...)
  local sum = 0

  for _, v in ipairs({...}) do
    assert(type(v) == "number", "non-number arg to +")
    sum = sum + v
  end

  return sum
end

local function minus(...)
  local sum = select(1, ...)

  for i = 2, select('#', ...) do
    local v = select(i, ...)
    assert(type(v) == "number", "non-number arg to `-`: " .. v)
    sum = sum - v
  end

  return sum
end

return {
  ["+"] = plus,
  ["-"] = minus,
}
