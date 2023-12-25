fn min[T : Compare](a : T, b : T) -> T {
  if a < b {
    a
  } else {
    b
  }
}

fn max[T : Compare](a : T, b : T) -> T {
  if a < b {
    b
  } else {
    a
  }
}

fn abs(this : Double) -> Double {
  if this < 0.0 {
    -this
  } else {
    this
  }
}

struct Ref[T] {
  mut value : T
}

fn Ref::make[T](value : T) -> Ref[T] {
  { value, }
}

fn filter[T](this : List[T], f : (T) -> Bool) -> List[T] {
  match this {
    Nil => Nil
    Cons(x, xs) => if f(x) {
      Cons(x, filter(xs, f))
    } else {
      filter(xs, f)
    }
  }
}

fn map[T, U](this : List[T], f : (T) -> U) -> List[U] {
  match this {
    Nil => Nil
    Cons(x, xs) => Cons(f(x), map(xs, f))
  }
}

fn tolist[T](this : Array[T]) -> List[T] {
  let len = this.length()
  fn aux(i) {
    if i < len {
      List::Cons(this[i], aux(i + 1))
    } else {
      List::Nil
    }
  }

  aux(0)
}

fn concat[X](this : List[X], ys : List[X]) -> List[X] {
  match this {
    Nil => ys
    Cons(x, rest) => Cons(x, concat(rest, ys))
  }
}

fn first[X](this : List[X], predicate : (X) -> Bool) -> Option[X] {
  match this {
    Nil => None
    Cons(x, xs) => if predicate(x) {
      Some(x)
    } else {
      first(xs, predicate)
    }
  }
}

fn last[X](this : List[X], predicate : (X) -> Bool) -> Option[X] {
  match this {
    Nil => None
    Cons(x, xs) => match last(xs, predicate) {
      Some(_) as ans => ans
      None => if predicate(x) {
        Some(x)
      } else {
        None
      }
    }
  }
}

fn at[X](this : List[X], index : Int) -> X {
  if index < 0 {
    abort("invalid index")
  }
  fn at_helper(l : List[X], index : Int) -> X {
    match l {
      Nil => abort("invalid index")
      Cons(x, xs) => if index == 0 {
        x
      } else {
        at_helper(xs, index - 1)
      }
    }
  }

  at_helper(this, index)
}
