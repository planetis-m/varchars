import std/varints

#bug: static range
type
  VarChar*[N: static[int]] = distinct array[N, byte] ## Do not use `N` less than `maxVarIntLen`

proc toVarChar*[N](data: string): VarChar[N] =
  let varintLen = writeVu64(toOpenArray(array[N, byte](result), 0, maxVarIntLen - 1),
      uint64(data.len))
  assert N - varintLen >= data.len
  #for i in 0 ..< min(N - varintLen, data.len):
    #array[N, byte](result)[i + varintLen] = byte(data[i])
  copyMem(addr(array[N, byte](result)[varintLen]), cstring(data), min(N - varintLen, data.len))

proc toString*[N](x: VarChar[N]): string =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(array[N, byte](x), 0, maxVarIntLen - 1), varint)
  assert N - varintLen >= int(varint)
  result = newString(min(int(varint), N - varintLen))
  #for i in 0 ..< result.len:
    #result[i] = char(array[N, byte](x)[i + varintLen])
  copyMem(cstring(result), unsafeAddr(array[N, byte](x)[varintLen]), result.len)

proc `$`*[N](x: VarChar[N]): string {.inline.} = toString(x)

# Comparisons
proc eqVarChars*[N](a, b: VarChar[N]): bool =
  var aLen: uint64
  let aVarintLen = readVu64(toOpenArray(array[N, byte](a), 0, maxVarIntLen - 1), aLen)
  var bLen: uint64
  let bVarintLen = readVu64(toOpenArray(array[N, byte](b), 0, maxVarIntLen - 1), bLen)
  if aLen == bLen:
    if aLen == 0: return true
    return equalMem(unsafeAddr(array[N, byte](a)[aVarintLen]),
        unsafeAddr(array[N, byte](b)[bVarintLen]), min(int(aLen), N - aVarintLen))

proc `==`*[N](a, b: VarChar[N]): bool {.inline.} = eqVarChars(a, b)

proc cmpVarChars*[N](a, b: VarChar[N]): int =
  var aLen: uint64
  let aVarintLen = readVu64(toOpenArray(array[N, byte](a), 0, maxVarIntLen - 1), aLen)
  var bLen: uint64
  let bVarintLen = readVu64(toOpenArray(array[N, byte](b), 0, maxVarIntLen - 1), bLen)
  let minlen = min(min(int(aLen), N - aVarintLen), min(int(bLen), N - bVarintLen))
  result = cmpMem(unsafeAddr(array[N, byte](a)[aVarintLen]),
      unsafeAddr(array[N, byte](b)[bVarintLen]), minLen)
  if result == 0:
    result = int(aLen) - int(bLen)

proc `<=`*[N](a, b: VarChar[N]): bool {.inline.} = cmpVarChars(a, b) <= 0
proc `<`*[N](a, b: VarChar[N]): bool {.inline.} = cmpVarChars(a, b) < 0
