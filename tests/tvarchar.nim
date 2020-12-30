import varchars, varchars/serialize, std/streams, eminim

block:
  let data = "Να φαίνεσαι αδύναμος όταν είσαι δυνατός και δυνατός όταν είσαι αδύναμος."
  let a = toVarChar[134](data)
  assert a.toString == data
block:
  let data = """Ο ασθενής είναι ο μεγαλύτερος κίνδυνος για τον υγιή. Δεν είναι από τον
πιο δυνατό που γίνεται η ζημιά σε έναν δυνατό άνθρωπό, αλλά από τον πιο αδύναμο."""
  let a = toVarChar[312](data)
  assert a.toString == data
block:
  let data = """Όπως και όλοι οι άλλοι, είμαι αδύναμος, οργισμένος και παραπλανημένος.
Είναι αυτή η αδυναμία που με κάνει συμπονετικό και με συνδέει με όλους τους ζωντανούς
οργανισμούς. Γνωρίζω ότι το κλειδί για την αληθινή φιλία είναι να μοιράζομαι τις
αδυναμίες μου. Πιστεύω ακράδαντα πως δεν είναι μόνο αυτό που λες που μετράει αλλά επίσης
πώς το λες. Η επιτυχία του επιχειρήματος σου εξαρτάται απόλυτα από τον τρόπο που το
παρουσιάζεις. Όπως και όλοι οι άλλοι, είμαι αδύναμος, οργισμένος και παραπλανημένος.
Είναι αυτή η αδυναμία που με κάνει συμπονετικό και με συνδέει με όλους τους ζωντανούς
οργανισμούς. Γνωρίζω ότι το κλειδί για την αληθινή φιλία είναι να μοιράζομαι τις
αδυναμίες μου. Η πολιτική είναι τόσο δύσκολη, που κατά κανόνα μόνο άνθρωποι που δεν είναι
εντελώς κατάλληλοι γι’ αυτή τη δουλειά είναι πεπεισμένοι ότι είναι. Το να φτάνεις στην
κορυφή έχει την κακή τάση να πείθει τους ανθρώπους ότι τελικά το σύστημα είναι εντάξει.
Σε μία πιο σοφή κοινωνία, σε μια κοινωνία που θα γνώριζε λίγο καλύτερα τον εαυτό της, η
ιδανική ερώτηση στο δείπνο του πρώτου κιόλας ραντεβού θα ήταν: «Και πώς είσαι, όταν
τρελαίνεσαι;». Είναι πιθανό να επιδιώκει να κάνει κανείς περιουσία για όχι πιο σοβαρό
λόγο από την επιθυμία να εξασφαλίσει το σεβασμό και την προσοχή ανθρώπων που διαφορετικά
δεν θα τον πρόσεχαν καθόλου."""
  let a = toVarChar[2400](data)
  assert a.toString == data
#block:
  #let data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit nec."
  #let a = toVarChar[60](data)
  #assert a.toString == data
block:
  let
    a = toVarChar[20]("Hello world")
    b = toVarChar[20]("Hello world")
  assert a == b
  assert a <= b
  assert a >= b
block:
  let
    a = toVarChar[20]("Hello world")
    b = toVarChar[20]("Hello worls")
  assert a != b
  assert a <= b
  assert a < b
  assert b > a
  assert b >= a
block:
  let
    a = toVarChar[20]("Hello")
    b = toVarChar[20]("Hello world")
  assert a != b
  assert a <= b
  assert a < b
  assert b > a
  assert b >= a
block:
  let
    a = toVarChar[20]("Hello world")
    b = toVarChar[20]("World")
  assert a != b
  assert a <= b
  assert a < b
  assert b > a
  assert b >= a
block: # zero length
  var a: VarChar[20]
  let b = toVarChar[20]("Hello world")
  assert a.toString.len == 0
  let c = toVarChar[20]("")
  assert a == c
  assert a != b
  assert a <= b
  assert a < b
  assert b > a
  assert b >= a
block:
  var s = newStringStream()
  let data = toVarChar[20]("Hello world")
  s.storeBin(data)
  s.setPosition(0)
  var a: VarChar[20]
  a.initFromBin(s)
  assert a == data
  assert a.toString == data.toString
block:
  var s = newStringStream()
  var data: VarChar[20]
  s.storeBin(data)
  s.setPosition(0)
  var a: VarChar[20]
  a.initFromBin(s)
  assert a == data
  assert a.toString == data.toString
block:
  var s = newStringStream()
  let data = toVarChar[20]("Hello world")
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(typeof data)
  assert a == data
  assert a.toString == data.toString
block:
  var s = newStringStream()
  var data: VarChar[20]
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(typeof data)
  assert a == data
  assert a.toString == data.toString
block:
  var s = newStringStream()
  let data = toVarChar[20]("Hello world")
  s.storeJson(data)
  s.setPosition(0)
  let a = s.jsonTo(string)
  assert a == data.toString
