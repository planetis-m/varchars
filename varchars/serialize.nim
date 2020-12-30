import ".."/varchars, std/[strutils, streams, varints, parsejson]

# Serialization
proc storeBin*[N](s: Stream; a: VarChar[N]) =
  var varint: uint64
  let varintLen = readVu64(toOpenArray(array[N, byte](a), 0, maxVarIntLen - 1), varint)
  assert N - varintLen >= int(varint)
  write(s, int64(varint)) #todo varints need stream support, however this is compatible with strings
  writeData(s, unsafeAddr(array[N, byte](a)[varintLen]), min(int(varint), N - varintLen))

proc initFromBin*[N](dst: var VarChar[N]; s: Stream) =
  let len = readInt64(s)
  let varintLen = writeVu64(toOpenArray(array[N, byte](dst), 0, maxVarIntLen - 1),
      uint64(len))
  assert N - varintLen >= int(len)
  let bLen = min(int(len), N - varintLen)
  if readData(s, addr(array[N, byte](dst)[varintLen]), bLen) != bLen:
    raise newException(IOError, "cannot read from stream")

proc escapeJsonUnquoted*(x: openArray[byte]; s: Stream) =
  ## Converts a string `s` to its JSON representation without quotes.
  ## Appends to ``result``.
  for c in x:
    case char(c)
    of '\L': s.write("\\n")
    of '\b': s.write("\\b")
    of '\f': s.write("\\f")
    of '\t': s.write("\\t")
    of '\v': s.write("\\u000b")
    of '\r': s.write("\\r")
    of '"': s.write("\\\"")
    of '\0'..'\7': s.write("\\u000" & $ord(c))
    of '\14'..'\31': s.write("\\u00" & toHex(ord(c), 2))
    of '\\': s.write("\\\\")
    else: s.write(c)

proc escapeJson*(s: Stream; x: openArray[byte]) =
  ## Converts a string `s` to its JSON representation with quotes.
  ## Appends to ``result``.
  s.write("\"")
  escapeJsonUnquoted(x, s)
  s.write("\"")

proc storeJson*[N](s: Stream; x: VarChar[N]) =
  ## Creates a new JString.
  var varint: uint64
  let varintLen = readVu64(toOpenArray(array[N, byte](x), 0, maxVarIntLen - 1), varint)
  assert N - varintLen >= int(varint)
  escapeJson(s, toOpenArray(array[N, byte](x), varintLen, min(int(varint), N - varintLen)))

proc initFromJson*[N](dst: var VarChar[N]; p: var JsonParser) =
  if p.tok == tkNull:
    dst = default(VarChar[N])
    discard getTok(p)
  elif p.tok == tkString:
    dst = toVarChar[N](p.a)
    discard getTok(p)
  else:
    raiseParseErr(p, "string or null")
