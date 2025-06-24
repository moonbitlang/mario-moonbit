///|
type Image @dom.HTMLImageElement

///|
let backg : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/background.png")
  img
}

///|
let block : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/blocks.png")
  img
}

///|
let items : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/items.png")
  img
}

///|
let enemy : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/enemies.png")
  img
}

///|
let small : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/mario-small.png")
  img
}

///|
let large : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/mario-large.png")
  img
}

///|
let panel : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/panel.png")
  img
}

///|
let ground : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/ground.png")
  img
}

///|
let chunk : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/chunks.png")
  img
}

///|
let score : Image = {
  let img : Image = @dom.document().create_element("img")
    |> @js.Value::cast_from
    |> @js.Value::cast
  img.inner().set_src("images/score.png")
  img
}
