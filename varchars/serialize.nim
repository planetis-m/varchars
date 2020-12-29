import ".."/varchars, std/[streams, varints]

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
