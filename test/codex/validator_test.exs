defmodule Codex.ValidatorTest do
  use ExUnit.Case, async: true

  defmodule ParamCodex do
    use Codex

    params schema(%{
             a: spec(is_binary())
           })

    def call(args, _) do
      {:ok, args |> Map.put(:b, 2)}
    end
  end

  defmodule B do
    use Codex

    params schema(%{
             a: spec(is_binary())
           })
  end

  defmodule NestedParamCodex do
    use Codex

    step B
  end

  test "ParamCodex errors with incorrect input" do
    assert ParamCodex.run(%{a: 1}) == {:error, [%{input: 1, path: [:a], spec: "is_binary()"}]}
  end

  test "ParamCodex succeeds with correct input" do
    assert ParamCodex.run(%{a: "1", c: 100}) ==
             {:ok, %{a: "1", b: 2, c: 100}}
  end

  test "NestedParamCodex errors with incorrect input" do
    assert NestedParamCodex.run(%{a: 1}) ==
             {:error, [%{input: 1, path: [:a], spec: "is_binary()"}]}
  end

  test "NestedParamCodex succeeds with correct input" do
    assert NestedParamCodex.run(%{a: "1", c: 100}) ==
             {:ok, %{a: "1", c: 100}}
  end

  test "ParamCodex succeeds with generated input" do
    assert {:ok, %{a: _, b: 2}} =
             ParamCodex.gen()
             |> Enum.take(1)
             |> List.first()
             |> ParamCodex.run()
  end
end
