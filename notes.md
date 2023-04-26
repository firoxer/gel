Gel
===



### Types

#### Booleans

    true
    false

Any value in a boolean context functions like `true` except `nil`. `nil` functions like `false`.

#### Keywords

    :keyword

Keywords are interned at creation. That means means that, relative to strings, they are expensive to modify but cheap to compare.

#### Strings

    "string"

Strings are byte arrays. That means means that, relative to keywords, they are cheap to modify but expensive to compare.

#### Numbers

    1234
    1234.5

Numbers are doubles.



### Control Flow

#### `match`

    (match expression
      comparison-1 branch-1
      comparsion-2 branch-2
      :else)

#### `if`

    (if condition
      (true-branch)
      (false-branch))

is equivalent to

    (match condition
      true (true-branch)
      false (false-branch))

#### `when`

    (when condition
      (branch))

is equivalent to

    (match condition
      true (branch)
      false nil)



### Predefined Functions

Name                  | Description
----------------------|--------------------------------------------------------------
`(print s ...args)`   | Print `s` to stdout with any %-characters replaced by `args`
`(println s ...args)` | Like `print` but with a succeeding newline
