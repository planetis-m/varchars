# Varchar data type

A `VarChar` type is defined as:

```nim
type
  VarChar*[N: static[int]] = distinct array[N, byte]
```

> `varchar` or Variable Character Field is a set of character data of indeterminate length.

This is a pure Nim implementation of a `varchar` used as a data type of a field in a Database,
that can hold alpha-numeric values. A `VarChar` can be of any length up to the limit `N`.

Stores the length at the start of the array using `writeVu64` from the `std/varints` module.
Length can occupy 1 to `maxVarIntLen` bytes.

## Usage

```nim
# Comparisons, needed for sorting
let a = toVarChar[85]("Appear weak when you are strong")
let b = toVarChar[85](", and strong when you are weak.")
assert a == a
assert a > b

# Appending using an intermediate buffer
var a = toVarChar[85]("Appear weak when you are strong")
var buffer = $a
buffer.add ", and strong when you are weak."
a = toVarChar(buffer)
echo a # "Appear weak when you are strong, and strong when you are weak."
```

## Limitations

- `add` can not be supported efficiently.
- Do not use `N` less than `maxVarIntLen`.
