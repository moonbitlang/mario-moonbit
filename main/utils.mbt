let seed : Ref[Int64] = { val: 0L }

fn random_lcg(seed : Int64) -> (Int, Int64) {
  let a = 25214903917L
  let c = 11L
  (
    seed.lsr(15).to_int(),
    (a * seed.land(0xFFFFFFFFFFFFL) + c).land(0xFFFFFFFFFFFFL),
  )
}

fn random(i : Int, j : Int) -> Int {
  let (r, s) = random_lcg(seed.val)
  seed.val = s
  i + r.mod_u(j - i)
}
