defmodule Codex do
  @external_resource "README.md"
  @moduledoc @external_resource
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @callback init(opts :: any) :: any
  @callback call(params :: any) :: {:ok, any} | {:error, any}

  defmacro __using__(opts) do
    input_validator = Keyword.get(opts, :validator, Codex.Validator.Norm)

    quote location: :keep do
      @behaviour Codex
      @before_compile Codex

      require unquote(input_validator)
      unquote(input_validator).setup()

      Module.register_attribute(__MODULE__, :steps, accumulate: true)
      Module.register_attribute(__MODULE__, :params, accumulate: false)

      import(unquote(__MODULE__))

      @impl true
      def init(opts) do
        opts
      end

      def __params__() do
        nil
      end

      @impl true
      def call(params, opts \\ [])

      def call({:ok, params}, opts) do
        {:ok, params}
      end

      def call({:error, params}, opts) do
        {:error, params}
      end

      def call(params, opts) do
        {:ok, params}
      end

      def run(params, opts \\ []) do
        Codex.Runner.run(__MODULE__, params, opts)
      end

      def validate(params) do
        Codex.Validator.validate(unquote(input_validator), params, __params__())
      end

      defoverridable init: 1, call: 2, __params__: 0
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc false
      def steps, do: @steps |> List.flatten() |> Enum.reverse()
    end
  end

  defmacro params(schema) do
    quote do
      def unquote(:__params__)() do
        unquote(schema)
      end
    end
  end

  defmacro step(name, opts \\ []) do
    quote do
      @steps {unquote(name), unquote(opts)}
    end
  end
end
