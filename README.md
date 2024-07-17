# Varchar: Nim Implementation of Variable-Length Character Arrays

`Varchar[N]` is a pure Nim implementation of variable-length character arrays,
mimicking the behavior of `varchar` in database systems.

## Definition

```nim
type
  Varchar*[N: static[int]] = distinct array[N, byte]
```

## Features

- Stores alpha-numeric values of variable length up to a maximum of `N` bytes.
- Encodes the string length at the start using `writeVu64` from `std/varints`.
- Length encoding occupies 1 to `maxVarIntLen` bytes.
- Supports comparison operations for sorting.

## Usage Example

```nim
import varchar

# Creating and comparing Varchars
let a = toVarchar[85]("Appear weak when you are strong")
let b = toVarchar[85]("and strong when you are weak.")
assert a == a
assert a > b

# Appending using an intermediate buffer
var c = toVarchar[85]("Appear weak when you are strong")
var buffer = $c
buffer.add ", and strong when you are weak."
c = toVarchar[85](buffer)
echo c # Outputs: "Appear weak when you are strong, and strong when you are weak."
```

## Limitations

1. Immutability: `Varchar` instances are immutable. Direct `add` operations are not supported.
2. Minimum Size: `N` must not be less than `maxVarIntLen`.
