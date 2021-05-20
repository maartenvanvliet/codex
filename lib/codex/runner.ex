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

        result =
          if function_exported?(mod, :run, 2) do
            init_opts = mod.init(opts)

            case mod.steps() do
              [:call] ->
                case mod.validate(acc) do
                  {:error, error} ->
                    {:error, error}

                  {:ok, result} ->
                    mod.call(result, init_opts)
                end

              _steps ->
                mod.run(acc, init_opts)
            end
          else
            apply(module, mod, [acc])
          end

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
