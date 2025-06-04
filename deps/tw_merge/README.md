# TwMerge

Utilities to merge TailwindCss classes.

This library is extracted from [Turboprop](https://github.com/leuchtturm-dev/turboprop/)

## Why another fork?
- `tails` has been soft deprecated because it has some issues which is not fixed. As discussed in [Elixir Forum](https://elixirforum.com/t/turboprop-toolkit-to-create-accessible-component-libraries/64228/3?u=bluzky)
- `turboprop` is archived too, so I create another repository and extract code to merge TailwindCss only.

## Installation
1. Adding `tw_merge` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tw_merge, "~> 0.1.0"}
  ]
end
```


2. Add `TwMerge.Cache` to children list in your `application.ex`

```elixir
    children = [
      ....
      TwMerge.Cache,
    ]
```
