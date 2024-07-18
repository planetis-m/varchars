import std/[hashes, varints]

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

proc raiseIndexDefect(i, n: int) {.noinline, noreturn.} =
  raise newException(IndexDefect, "index " & $i & " not in 0 .. " & $n)

template checkBounds(i, n) =
  when compileOption("boundChecks"):
    {.line.}:
      if i < 0 or i >= n:
        raiseIndexDefect(i, n-1)

proc `[]`*[N](x: Varchar[N]; i: int): char {.inline.} =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  checkBounds(i, min(int(varint), N - varintLen))
  char(@^x[varintLen + i])

proc `[]=`*[N](x: var Varchar[N]; i: int; val: char) {.inline.} =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  checkBounds(i, min(int(varint), N - varintLen))
  @^x[varintLen + i] = byte(val)

proc `[]`*[N](x: Varchar[N]; i: BackwardsIndex): char {.inline.} =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  let len = min(int(varint), N - varintLen)
  checkBounds(len - i.int, len)
  char(@^x[varintLen + len - i.int])

proc `[]=`*[N](x: var Varchar[N]; i: BackwardsIndex; val: char) {.inline.} =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  let len = min(int(varint), N - varintLen)
  checkBounds(len - i.int, len)
  @^x[varintLen + len - i.int] = byte(val)

iterator items*[N](a: Varchar[N]): char {.inline.} =
  var i = 0
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^a, 0, maxVarIntLen - 1), varint)
  let L = min(int(varint), N - varintLen)
  while i < L:
    yield char(@^a[varintLen + i])
    inc(i)

template toOpenArray*[N](s: Varchar[N]; first, last: int): untyped =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^s, 0, maxVarIntLen - 1), varint)
  toOpenArray(cast[cstring](addr @^s[varintLen]), first, last)

template toOpenArray*[N](s: Varchar[N]): untyped =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^s, 0, maxVarIntLen - 1), varint)
  toOpenArray(cast[cstring](addr @^s[varintLen]), 0, min(int(varint), N - varintLen)-1)

proc hash*[N](x: Varchar[N]): Hash =
  hash(toOpenArray(x))
