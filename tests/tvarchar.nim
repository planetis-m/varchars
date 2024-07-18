import varchars

block:
  let data = "Να φαίνεσαι αδύναμος όταν είσαι δυνατός και δυνατός όταν είσαι αδύναμος."
  let a = toVarchar[134](data)
  assert a.toString == data
  assert a.len == len(data)
  assert toOpenArray(a) == data
block:
  let data = """Ο ασθενής είναι ο μεγαλύτερος κίνδυνος για τον υγιή. Δεν είναι από τον
πιο δυνατό που γίνεται η ζημιά σε έναν δυνατό άνθρωπό, αλλά από τον πιο αδύναμο."""
  let a = toVarchar[312](data)
  assert a.toString == data
  assert a.len == len(data)
  assert toOpenArray(a) == data
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
  let a = toVarchar[2400](data)
  assert a.toString == data
  assert a.len == len(data)
  assert toOpenArray(a) == data
# block:
#   let data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit nec."
#   let a = toVarchar[60](data)
#   assert a.toString == data
#   assert a.len == len(data)
block:
  let
    a = toVarchar[20]("Hello world")
    b = toVarchar[20]("Hello world")
  assert a[0] == 'H'
  assert a[1] == 'e'
  assert a[2] == 'l'
  assert a[3] == 'l'
  assert a[4] == 'o'
  assert a[5] == ' '
  assert a[^5] == 'w'
  assert a[^4] == 'o'
  assert a[^3] == 'r'
  assert a[^2] == 'l'
  assert a[^1] == 'd'
  assert a == b
  assert a <= b
  assert a >= b
  assert hash(a) == hash(b)
block:
  let
    a = toVarchar[20]("Hello world")
    b = toVarchar[20]("Hello worls")
  assert a != b
  assert a <= b
  assert a < b
  assert b > a
  assert b >= a
  assert hash(a) != hash(b)
block:
  var
    a = toVarchar[20]("Hello")
    b = toVarchar[20]("Hello world")
  assert a != b
  assert a <= b
  assert a < b
  assert b > a
  assert b >= a
  assert hash(a) != hash(b)
  assert toOpenArray(a) == "Hello"
  assert toOpenArray(a, 0, 4) == "Hello"
  a[0] = 'w'
  a[1] = 'o'
  a[2] = 'r'
  a[3] = 'l'
  a[4] = 'd'
  assert a[^5] == 'w'
  assert a[^4] == 'o'
  assert a[^3] == 'r'
  assert a[^2] == 'l'
  assert a[^1] == 'd'
block:
  var
    a = toVarchar[20]("Hello world")
    b = toVarchar[20]("World")
  assert a != b
  assert a <= b
  assert a < b
  assert b > a
  assert b >= a
  assert hash(a) != hash(b)
  assert toOpenArray(b) == "World"
  assert toOpenArray(b, 0, 4) == "World"
  b[^5] = 'h'
  b[^4] = 'e'
  b[^3] = 'l'
  b[^2] = 'l'
  b[^1] = 'o'
  assert b[0] == 'h'
  assert b[1] == 'e'
  assert b[2] == 'l'
  assert b[3] == 'l'
  assert b[4] == 'o'
block: # zero length
  var a: Varchar[20]
  let b = toVarchar[20]("Hello world")
  assert a.len == 0
  let c = toVarchar[20]("")
  assert a == c
  assert a != b
  assert a <= b
  assert a < b
  assert b > a
  assert b >= a
  var s = ""
  for c in b.items:
    s.add c
  assert s == "Hello world"
  assert hash(a) != hash(b)
