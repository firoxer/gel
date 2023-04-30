local eval = require("src.eval")
local qol = require("src.qol")
local read = require("src.read")

return function(source)
  qol.set_source(source)
  local ast = read(source)
  local result = eval(ast)
  return result
end
