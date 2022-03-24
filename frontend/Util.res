open Belt

let s = React.string
let itos = i => i->Int.toString->React.string

let joinWith = Js.Array.joinWith

let map2Tuple: ('a => 'b, ('a, 'a)) => ('b, 'b) = (op, tup) => {
  let (l, r) = tup
  (op(l), op(r))
}

let first: (('a, 'b)) => 'a = ((l, _)) => l
let second: (('a, 'b)) => 'b = ((_, r)) => r

let identity: 'a => 'a = v => v

let partitionErrors: array<Result.t<'succ, 'err>> => (array<'err>, array<'succ>) = arr => {
  Array.reduce(arr, ([], []), (accum, res) => {
    let (errs, succs) = accum
    switch res {
    | Error(err) => (Array.concat(errs, [err]), succs)
    | Ok(succ) => (errs, Array.concat(succs, [succ]))
    }
  })
}

let trimLower: string => string = str => {
  str->Js.String.toLowerCase->Js.String.trim
}

let optionToError: (option<'succ>, 'err) => Result.t<'succ, 'err> = (opt, err) =>
  opt->Option.mapWithDefault(Error(err), rawSucc => Ok(rawSucc))

let unzipFour: array<(('a, 'b), ('c, 'd), ('e, 'f), ('g, 'h))> => (
  array<('a, 'b)>,
  array<('c, 'd)>,
  array<('e, 'f)>,
  array<('g, 'h)>,
) = arr => {
  (
    arr->Array.map(((a, _, _, _)) => a),
    arr->Array.map(((_, b, _, _)) => b),
    arr->Array.map(((_, _, c, _)) => c),
    arr->Array.map(((_, _, _, d)) => d),
  )
}

let asUnitPromise: Js.Promise.t<_> => Js.Promise.t<unit> = orig => {
  open Js.Promise
  orig |> then_(_ => () |> resolve)
}
