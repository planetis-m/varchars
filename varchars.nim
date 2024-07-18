import std/[hashes, varints]

type
  Varchar*[N: static[int]] = distinct array[N, byte] ## Do not use `N` less than `maxVarIntLen`

template `@^`[N](x: Varchar[N]): untyped =
  array[N, byte](x)

template readVarcharLen(x, N, varint, varintLen, len: untyped): untyped =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(@^x, 0, maxVarIntLen - 1), varint)
  let len = min(int(varint), N - varintLen)

proc toVarchar*[N](data: string): Varchar[N] =
  static: assert N >= maxVarIntLen
  let varintLen = writeVu64(toOpenArray(@^result, 0, maxVarIntLen - 1),
      uint64(data.len))
  assert N - varintLen >= data.len
  # for i in 0 ..< min(N - varintLen, data.len):
  #   @^result[i + varintLen] = byte(data[i])
  copyMem(addr @^result[varintLen], cstring(data), min(N - varintLen, data.len))

proc toString*[N](x: Varchar[N]): string =
  readVarcharLen(x, N, varint, varintLen, len)
  assert N - varintLen >= int(varint)
  result = newStringUninit(len)
  # for i in 0 ..< result.len:
  #   result[i] = char(@^x[i + l])
  copyMem(cstring(result), addr @^x[varintLen], result.len)

proc `$`*[N](x: Varchar[N]): string {.inline.} = toString(x)

# Comparisons
proc `==`*[N](a, b: Varchar[N]): bool {.inline.} = @^a == @^b

proc cmp*[N](a, b: Varchar[N]): int =
  readVarcharLen(a, N, aVarint, aVarintLen, aLen)
  readVarcharLen(b, N, bVarint, bVarintLen, bLen)
  let minLen = min(aLen, bLen)
  result = cmpMem(addr @^a[aVarintLen], addr @^b[bVarintLen], minLen)
  if result == 0:
    result = int(aVarint) - int(bVarint)

proc `<=`*[N](a, b: Varchar[N]): bool {.inline.} = cmp(a, b) <= 0
proc `<`*[N](a, b: Varchar[N]): bool {.inline.} = cmp(a, b) < 0

proc len*[N](x: Varchar[N]): int =
  readVarcharLen(x, N, varint, varintLen, len)
  result = len

proc raiseIndexDefect(i, n: int) {.noinline, noreturn.} =
  raise newException(IndexDefect, "index " & $i & " not in 0 .. " & $n)

template checkBounds(i, n) =
  when compileOption("boundChecks"):
    {.line.}:
      if i < 0 or i >= n:
        raiseIndexDefect(i, n-1)

proc `[]`*[N](x: Varchar[N]; i: int): char {.inline.} =
  readVarcharLen(x, N, varint, varintLen, len)
  checkBounds(i, len)
  char(@^x[varintLen + i])

proc `[]=`*[N](x: var Varchar[N]; i: int; val: char) {.inline.} =
  readVarcharLen(x, N, varint, varintLen, len)
  checkBounds(i, len)
  @^x[varintLen + i] = byte(val)

proc `[]`*[N](x: Varchar[N]; i: BackwardsIndex): char {.inline.} =
  readVarcharLen(x, N, varint, varintLen, len)
  checkBounds(len - i.int, len)
  char(@^x[varintLen + len - i.int])

proc `[]=`*[N](x: var Varchar[N]; i: BackwardsIndex; val: char) {.inline.} =
  readVarcharLen(x, N, varint, varintLen, len)
  checkBounds(len - i.int, len)
  @^x[varintLen + len - i.int] = byte(val)

iterator items*[N](a: Varchar[N]): char {.inline.} =
  var i = 0
  readVarcharLen(a, N, varint, varintLen, L)
  while i < L:
    yield char(@^a[varintLen + i])
    inc(i)

template toOpenArray*[N](s: Varchar[N]; first, last: int): untyped =
  readVarcharLen(s, N, varint, varintLen, L)
  checkBounds(first, L)
  checkBounds(last, L)
  toOpenArray(cast[cstring](addr @^s[varintLen]), first, last)

template toOpenArray*[N](s: Varchar[N]): untyped =
  readVarcharLen(s, N, varint, varintLen, L)
  toOpenArray(cast[cstring](addr @^s[varintLen]), 0, L-1)

proc hash*[N](x: Varchar[N]): Hash =
  hash(toOpenArray(x))
