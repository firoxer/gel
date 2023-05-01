require("test.util")

assert_returns("fine", [[
  (let (f (fn ()
            "fine"))
    (f))
]])

assert_returns("fine too", [[
  (let (f (fn ()
            "fine"
            "fine too"))
    (f))
]])

assert_error("no parameters", [[
  (let (f (fn))
    (f))
]])

assert_error("no body", [[
  (let (f (fn ()))
    (f))
]])

assert_error("wrong number of arguments", [[
  (let (f (fn (a b)
            (+ a b)))
    (f 1))
]])
