defmodule Codex.ResultTest do
  use ExUnit.Case, async: true

  defmodule AcceptTerms do
    use Codex

    defstruct [:accepted]

    step :agree
    step :two

    def agree(args) do
      %AcceptTerms{accepted: args[:test]}
    end

    def two(args) do
      {:ok, Map.put(args, :two, 2)}
    end
  end

  defimpl Codex.Result, for: AcceptTerms do
    def halt(%{accepted: false}), do: {:halt, %{accepted: false}}
    def halt(%{accepted: true}), do: {:ok, %{accepted: true}}
  end

  defmodule SimpleAcceptTerms do
    use Codex

    defstruct [:accepted]

    def call(args, _) do
      %SimpleAcceptTerms{accepted: args[:test]}
    end
  end

  test "SimpleAcceptTerms works for call" do
    assert SimpleAcceptTerms.run(%{test: true}) == {:ok, %{accepted: true}}
  end

  test "SimpleAcceptTerms works for halting" do
    assert SimpleAcceptTerms.run(%{test: false}) == {:error, %{accepted: false}}
  end

  defimpl Codex.Result, for: SimpleAcceptTerms do
    def halt(%{accepted: false}), do: {:halt, %{accepted: false}}
    def halt(%{accepted: true}), do: {:ok, %{accepted: true}}
  end
end
