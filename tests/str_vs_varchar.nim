import times, stats, strformat
import ../varchars, algorithm, random

const
  DataLen = 100
  MaxIter = 10_000

type
  Customer1* = object
    registered*, verified*: Time
    username*: VarChar[125]
    name*, surname*: VarChar[125]
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

proc test1 =
  warmup()
  var data = newSeq[Customer1](DataLen)
  for i in 0 ..< DataLen:
    data[i] = Customer1(registered: getTime(), username: toVarChar[125](fakeName(125)))
  var lastTime = data[^1].registered
  bench("Sort object with Varchar", MaxIter):
    shuffle(data)
    sort(data, proc (x, y: Customer1): int = cmpVarchars(x.username, y.username))
    lastTime = data[^1].registered
  echo lastTime

proc test2 =
  warmup()
  var data = newSeq[Customer2](DataLen)
  for i in 0 ..< DataLen:
    data[i] = Customer2(registered: getTime(), username: fakeName(125))
  var lastTime = data[^1].registered
  bench("Sort object with strings", MaxIter):
    shuffle(data)
    sort(data, proc (x, y: Customer2): int = cmp(x.username, y.username))
    lastTime = data[^1].registered
  echo lastTime

proc test3 =
  warmup()
  var data = newSeq[VarChar[125]](DataLen)
  for i in 0 ..< DataLen:
    data[i] = toVarChar[125](fakeName(125))
  bench("Sort Varchar", MaxIter):
    shuffle(data)
    sort(data, cmpVarchars[125])

proc test4 =
  warmup()
  var data = newSeq[string](DataLen)
  for i in 0 ..< DataLen:
    data[i] = fakeName(125)
  bench("Sort string", MaxIter):
    shuffle(data)
    sort(data, cmp)

test4()
test3()
