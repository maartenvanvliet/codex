defmodule Codex.Validator do
  @moduledoc """
  Behaviour for validating incoming params

  """
  @callback validate(params :: any, schema :: any) :: {:ok, any} | {:error, any}
  @macrocallback setup() :: Macro.t()

  @doc false
  def validate(module, params, schema) do
    case schema do
      nil -> {:ok, params}
      schema -> module.validate(params, schema)
    end
  end
end
