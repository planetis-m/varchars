import times, stats, strformat
import ".."/varchars, algorithm, random

const
  DataLen = 100
  MaxIter = 10_000

type
  Customer1* = object
    registered*, verified*: Time
    username*: Varchar[126]
    name*, surname*: Varchar[126]

  Customer2* = object
    registered*, verified*: Time
    username*: string
    name*, surname*: string

proc warmup() =
   # Warmup - make sure cpu is on max perf
   let start = cpuTime()
   var a = 123
   for i in 0 ..< 300_000_000:
      a += i * i mod 456
      a = a mod 789
   let dur = cpuTime() - start
   echo &"Warmup: {dur:>4.4f} s ", a

proc printStats(name: string, stats: RunningStat, dur: float) =
  echo &"""{name}:
  Collected {stats.n} samples in {dur:.4} seconds
  Average time: {stats.mean * 1000:.4} ms
  Stddev  time: {stats.standardDeviationS * 1000:.4} ms
  Min     time: {stats.min * 1000:.4} ms
  Max     time: {stats.max * 1000:.4} ms"""

template bench(name, samples, code: untyped) =
   var stats: RunningStat
   let globalStart = cpuTime()
   for i in 0 ..< samples:
      let start = cpuTime()
      code
      let duration = cpuTime() - start
      stats.push duration
   let globalDuration = cpuTime() - globalStart
   printStats(name, stats, globalDuration)

proc fakeName(maxLen: Natural): string =
  result = newString(rand(maxLen))
  for i in 0 ..< result.len:
    result[i] = rand('A'..'Z')

template modify(x, prc: untyped) =
  for i in countdown(x.high, 1):
    if rand(1.0) > 0.98:
      x[i] = prc

proc test1 =
  warmup()
  var data = newSeq[Customer1](DataLen)
  for i in 0 ..< DataLen:
    data[i] = Customer1(registered: getTime(), username: toVarchar[126](fakeName(125)))
  var lastTime = data[^1].registered
  bench("Sort object with Varchar", MaxIter):
    modify(data, Customer1(registered: getTime(), username: toVarchar[126](fakeName(125))))
    sort(data, proc (x, y: Customer1): int = cmp(x.username, y.username))
    lastTime = data[^1].registered
  echo lastTime

proc test2 =
  warmup()
  var data = newSeq[Customer2](DataLen)
  for i in 0 ..< DataLen:
    data[i] = Customer2(registered: getTime(), username: fakeName(125))
  var lastTime = data[^1].registered
  bench("Sort object with strings", MaxIter):
    modify(data, Customer2(registered: getTime(), username: fakeName(125)))
    sort(data, proc (x, y: Customer2): int = cmp(x.username, y.username))
    lastTime = data[^1].registered
  echo lastTime

# Benchmark heap containers with a single string-like type.

proc test3 =
  warmup()
  var data = newSeq[Varchar[126]](DataLen)
  for i in 0 ..< DataLen:
    data[i] = toVarchar[126](fakeName(125))
  bench("Sort Varchar", MaxIter):
    modify(data, toVarchar[126](fakeName(125)))
    sort(data, cmp[126])

proc test4 =
  warmup()
  var data = newSeq[string](DataLen)
  for i in 0 ..< DataLen:
    data[i] = fakeName(125)
  bench("Sort string", MaxIter):
    modify(data, fakeName(125))
    sort(data, cmp)

proc toArrayChar[N: static[int]](data: string): array[N, char] =
  for i in 0 ..< min(N, data.len):
    result[i] = data[i]

proc cmpArrayChars[N: static[int]](x, y: array[N, char]): int =
  result = cmpMem(addr x, addr y, N)

proc test5 =
  warmup()
  var data = newSeq[array[125, char]](DataLen)
  for i in 0 ..< DataLen:
    data[i] = fakeName(125).toArrayChar[:125]
  bench("Sort char arrays", MaxIter):
    modify(data, fakeName(125).toArrayChar[:125])
    sort(data, cmpArrayChars[125])

test1()
test2()
test3()
test4()
test5()
