defmodule Codex.Runner do
  @moduledoc false
  @doc false
  def run(module, params, opts \\ []) do
    case module.validate(params) do
      {:error, error} ->
        {:error, error}

      {:ok, result} ->
        call(module, result, module.init(opts))
    end
  end

  @doc false
  defp call(module, params, global_opts) do
    result =
      module.steps
      |> Enum.reduce_while(params, fn step, acc ->
        {mod, opts} = step_invocation(step)

        opts = Keyword.merge(opts, global_opts)

        result = Codex.Step.run(acc, module, mod, opts)

        case Codex.Result.halt(result) do
          {:halt, data} ->
            {:halt, {:error, data}}

          {:ok, params} ->
            {:cont, params}
        end
      end)

    process_result(result)
  end

  defp process_result(result) do
    case Codex.Result.halt(result) do
      {:halt, data} ->
        {:error, data}

      {:ok, params} ->
        {:ok, params}
    end
  end

  defp step_invocation({module, config}) do
    {module, config}
  end

  defp step_invocation(module) do
    {module, []}
  end
end
