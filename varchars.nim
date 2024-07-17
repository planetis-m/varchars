import std/varints

type
  VarChar*[N: static[int]] = distinct array[N, byte] ## Do not use `N` less than `maxVarIntLen`

template `@^`(x: VarChar): untyped =
  array[N, byte](x)

proc toVarChar*[N](data: string): VarChar[N] =
  let varintLen = writeVu64(toOpenArray(@^result, 0, maxVarIntLen - 1),
      uint64(data.len))
  assert N - varintLen >= data.len
  # for i in 0 ..< min(N - varintLen, data.len):
  #   @^result[i + varintLen] = byte(data[i])
  copyMem(addr @^result[varintLen], cstring(data), min(N - varintLen, data.len))

proc toString*[N](x: VarChar[N]): string =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  assert N - varintLen >= int(varint)
  result = newString(min(int(varint), N - varintLen))
  # for i in 0 ..< result.len:
  #   result[i] = char(@^x[i + varintLen])
  copyMem(cstring(result), addr @^x[varintLen], result.len)

proc `$`*[N](x: VarChar[N]): string {.inline.} = toString(x)

# Comparisons
proc eqVarChars[N](a, b: VarChar[N]): bool =
  var aLen: uint64
  let aVarintLen = readVu64(toOpenArray(@^a, 0, maxVarIntLen - 1), aLen)
  var bLen: uint64
  let bVarintLen = readVu64(toOpenArray(@^b, 0, maxVarIntLen - 1), bLen)
  if aLen == bLen:
    if aLen == 0: return true
    return equalMem(addr @^a[aVarintLen], addr @^b[bVarintLen],
                    min(int(aLen), N - aVarintLen))

proc `==`*[N](a, b: VarChar[N]): bool {.inline.} = @^a == @^b # eqVarChars(a, b)

proc cmpVarChars[N](a, b: VarChar[N]): int =
  var aLen: uint64
  let aVarintLen = readVu64(toOpenArray(@^a, 0, maxVarIntLen - 1), aLen)
  var bLen: uint64
  let bVarintLen = readVu64(toOpenArray(@^b, 0, maxVarIntLen - 1), bLen)
  let minLen = min(min(int(aLen), N - aVarintLen), min(int(bLen), N - bVarintLen))
  result = cmpMem(addr @^a[aVarintLen], addr @^b[bVarintLen], minLen)
  if result == 0:
    result = int(aLen) - int(bLen)

proc `<=`*[N](a, b: VarChar[N]): bool {.inline.} = cmpVarChars(a, b) <= 0
proc `<`*[N](a, b: VarChar[N]): bool {.inline.} = cmpVarChars(a, b) < 0

proc len*[N](x: VarChar[N]): int =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  assert N - varintLen >= int(varint)
  result = int(varint)
