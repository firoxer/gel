local gel = require("src")

function assert_returns(value, src)
  local returned
  local ok, err = pcall(function()
    returned = gel.interpret(src)
  end)
  
  if not ok then
    error("should have no errors; had: " .. err, 2)
  end
  
  if returned ~= value then
    trace(returned)
    error("bad return value\n\texpected: " .. value .. "\n\tactual:   " .. tostring(returned), 2)
  end
end

function assert_error(msg, src)
  local ok, err = pcall(function()
    gel.interpret(src)
  end)

  if ok then
    error("should throw an error", 2)
  elseif not err:match(msg) then
    error("error message did not match\n\texpected: " .. msg .. "\n\tactual:   " .. err, 2)
  end
end
