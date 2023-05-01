local function equals(...)
  local first = select(1, ...)

  for i = 2, select('#', ...) do
    local nth = select(i, ...)
    if first ~= nth then
      return false
    end
  end

  return true
end

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

local function times(...)
  local result = select(1, ...)

  for i = 2, select('#', ...) do
    local v = select(i, ...)
    assert(type(v) == "number", "non-number arg to `*`: " .. v)
    result = result * v
  end

  return result
end

local function println(...)
  print(...)
end

return {
  ["="] = equals,
  ["+"] = plus,
  ["-"] = minus,
  ["*"] = times,
  println = println,
}
