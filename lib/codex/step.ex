defmodule Codex.Step do
  @moduledoc false
  def run(acc, module, fun, opts) do
    if function_exported?(fun, :run, 2) do
      init_opts = fun.init(opts)

      case fun.steps() do
        [:call] ->
          case fun.validate(acc) do
            {:error, error} ->
              {:error, error}

            {:ok, result} ->
              fun.call(result, init_opts)
          end

        _steps ->
          fun.run(acc, init_opts)
      end
    else
      if function_exported?(module, fun, 2) do
        apply(module, fun, [acc, opts])
      else
        apply(module, fun, [acc])
      end
    end
  end
end
