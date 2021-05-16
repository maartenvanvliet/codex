defmodule Codex.Validator.Norm do
  @moduledoc """
  Validator using Norm

  Adds `schema` and `gen` functions on the Codex module.

  `schema/0` returns Norm schema of the module
  `gen/0` returns StreamData generator based on schema


  ## Example

      defmodule NormCodex do
        use Codex

        params schema(%{
                name: spec(is_binary())
              })

        def call(args, _) do
          {:ok, args |> Map.put(:b, 2)}
        end
      end

      iex> NormCodex.schema
      #Norm.Schema<%{name: #Norm.Spec<is_binary()>}>

      iex> NormCodex.gen |> Enum.take(3)
      [%{name: "_"}, %{name: ""}, %{name: <<191, 134, 10>>}]
  """
  @behaviour Codex.Validator

  @impl true
  defmacro setup() do
    quote do
      import Norm

      def schema do
        __params__()
      end

      def gen do
        schema() |> Norm.gen()
      end
    end
  end

  @impl true
  def validate(input, schema) do
    Norm.conform(input, schema)
  end
end
