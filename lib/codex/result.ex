defprotocol Codex.Result do
  @moduledoc false
  @fallback_to_any true
  @spec halt(data :: any) :: {:halt, term} | {:ok, term}
  def halt(data)
end

defimpl Codex.Result, for: Any do
  def halt({:error, data}), do: {:halt, data}
  def halt({:ok, data}), do: {:ok, data}
  def halt(data), do: {:ok, data}
end
