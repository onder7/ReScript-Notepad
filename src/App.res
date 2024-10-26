@react.component
let make = () => {
  let (count, setCount) = React.useState(() => 0)

  <div>
    <h1> {React.string("Hello from ReScript and React!")} </h1>
    <button onClick={_ => setCount(prev => prev + 1)}>
      {React.string("Count: " ++ Belt.Int.toString(count))}
    </button>
  </div>
}