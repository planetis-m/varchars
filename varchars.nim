import std/varints

type
  Varchar*[N: static[int]] = distinct array[N, byte] ## Do not use `N` less than `maxVarIntLen`

template `@^`(x: Varchar): untyped =
  array[N, byte](x)

proc toVarchar*[N](data: string): Varchar[N] =
  let varintLen = writeVu64(toOpenArray(@^result, 0, maxVarIntLen - 1),
      uint64(data.len))
  assert N - varintLen >= data.len
  # for i in 0 ..< min(N - varintLen, data.len):
  #   @^result[i + varintLen] = byte(data[i])
  copyMem(addr @^result[varintLen], cstring(data), min(N - varintLen, data.len))

proc toString*[N](x: Varchar[N]): string =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  assert N - varintLen >= int(varint)
  result = newStringUninit(min(int(varint), N - varintLen))
  # for i in 0 ..< result.len:
  #   result[i] = char(@^x[i + varintLen])
  copyMem(cstring(result), addr @^x[varintLen], result.len)

proc `$`*[N](x: Varchar[N]): string {.inline.} = toString(x)

# Comparisons
proc `==`*[N](a, b: Varchar[N]): bool {.inline.} = @^a == @^b

proc cmpVarchars*[N](a, b: Varchar[N]): int =
  var aLen: uint64
  let aVarintLen = readVu64(toOpenArray(@^a, 0, maxVarIntLen - 1), aLen)
  var bLen: uint64
  let bVarintLen = readVu64(toOpenArray(@^b, 0, maxVarIntLen - 1), bLen)
  let minLen = min(min(int(aLen), N - aVarintLen), min(int(bLen), N - bVarintLen))
  result = cmpMem(addr @^a[aVarintLen], addr @^b[bVarintLen], minLen)
  if result == 0:
    result = int(aLen) - int(bLen)

proc `<=`*[N](a, b: Varchar[N]): bool {.inline.} = cmpVarchars(a, b) <= 0
proc `<`*[N](a, b: Varchar[N]): bool {.inline.} = cmpVarchars(a, b) < 0

proc len*[N](x: Varchar[N]): int =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  result = min(int(varint), N - varintLen)
