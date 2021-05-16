# Codex

## [![Hex pm](http://img.shields.io/hexpm/v/codex.svg?style=flat)](https://hex.pm/packages/codex) [![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/codex) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)![.github/workflows/elixir.yml](https://github.com/maartenvanvliet/codex/workflows/.github/workflows/elixir.yml/badge.svg)

<!-- MDOC !-->

Library to facilitate control flow, providing a Plug like interface.

## Installation

```elixir
def deps do
  [
    {:codex, "~> 0.9.0"}
  ]
end
```

## Usage

In it's simplest form Codex gives you a module with a `call/2` function that will be
with `run/2`

```elixir
defmodule SimpleFlow do
  use Codex

  def call(params, _) do
    {:ok, %{params | test: false}}
  end
end

iex> Simple.run(%{test: true})
{:ok, %{test: false}}
```

### Adding function steps

You can add extra steps that are run before the `call/2`. These are passed the params and should return
an `:ok/:error` tuple. It halts the flow when an `:error` tuple is returned. The second element of the :ok tuple is passed to the next step.

```elixir
defmodule FunctionFlow do
  use Codex

  step :double
  step :add_one

  def call(params, _) do
    {:ok, params}
  end

  def double(params) do
    {:ok, %{params | test: params[:test] * 2}}
  end

  def add_one(params) do
    {:ok, %{params | test: params[:test] + 1}}
  end
end

iex> FunctionFlow.run(%{test: 2})
{:ok, %{test: 5}}
```

#### Adding module steps

Additionaly, you can also extract common functionality into modules and use those as steps.

```elixir
defmodule Double do
  use Codex

  # optional init
  def init(opts) do
    opts[:key]
  end

  def call(params, key) do
    params = Map.put(params, key, params[key] * 2)
    {:ok, params}
  end
end

defmodule ModuleFlow do
  use Codex

  # the second argument is passed to the init function
  step Double, key: :test

  def call(params, _) do
    {:ok, params}
  end
end

iex> ModuleFlow.run(%{test: 2})
{:ok, %{test: 4}}
```

A module step can also contain steps itself, allowing you to compose steps. These are executed before the `call/2` function. E.g. you can add an `inspect` step.

```elixir
defmodule Double do
  use Codex

  step :inspect

  def call(params, opts) do
    params = Map.put(params, opts[:key], params[opts[:key]] * 2)
    {:ok, params}
  end

  def inspect(params) do
    IO.inspect(params, label: "double")
  end
end

# outputs: "double: %{test: 2}" in the inspect step
iex> ModuleFlow.run(%{test: 2})
{:ok, %{test: 4}}
```

#### Checking parameters

Codex modules can optionally check their input before execution. This is by default done with `Norm`.

```elixir
defmodule ParamCheck do
  use Codex

  params schema(%{
            name: spec(is_binary())
          })

  def call(params, _) do
    {:ok, params.name}
  end
end

iex> ParamCheck.run(%{name: "Miles"})
{:ok, "Miles"}

iex> ParamCheck.run(%{name: 1})
{:error, [%{input: 1, path: [:name], spec: "is_binary()"}]}
```

## Inspiration

This library draws inspiration from https://github.com/zorbash/opus and https://github.com/madeinussr/exop
