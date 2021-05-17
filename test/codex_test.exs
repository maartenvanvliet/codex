defmodule CodexTest do
  use ExUnit.Case

  defmodule NoopCodex do
    use Codex
  end

  defmodule SimpleCodex do
    use Codex

    def call(args, _) do
      {:ok, args |> Map.put(:b, 2)}
    end
  end

  defmodule StepFnCodex do
    use Codex

    step :b
    step :c

    def b(args) do
      {:ok, args |> Map.put(:b, 2)}
    end

    def c(args) do
      {:ok, args |> Map.put(:c, 3)}
    end
  end

  defmodule StepModCodex do
    use Codex

    defmodule B do
      use Codex

      def call(args, opts) do
        case args[:fail] do
          :b -> {:error, args}
          _ -> {:ok, args |> Map.put(:b, opts[:val])}
        end
      end
    end

    defmodule C do
      use Codex

      def init(opts) do
        [val: opts[:val] + 1]
      end

      def call(args, opts) do
        case args[:fail] do
          :c -> {:error, args}
          _ -> {:ok, args |> Map.put(:c, opts[:val])}
        end
      end
    end

    step B, val: 2
    step C, val: 3
  end

  defmodule StepNestedModCodex do
    use Codex

    defmodule B do
      use Codex

      defmodule C do
        use Codex

        def call(args, _opts) do
          {:ok, [:c] ++ args}
        end
      end

      step C

      def call(args, _opts) do
        {:ok, [:b] ++ args}
      end
    end

    step B, val: 2
  end

  test "NoopCodex does nothing" do
    assert NoopCodex.run(%{a: 1}) == {:ok, %{a: 1}}
  end

  test "SimpleCodex calls run" do
    assert SimpleCodex.run(%{a: 1}) == {:ok, %{a: 1, b: 2}}
  end

  test "StepFnCodex calls functions" do
    assert StepFnCodex.run(%{a: 1}) == {:ok, %{a: 1, b: 2, c: 3}}
  end

  test "StepModCodex calls modules" do
    assert StepModCodex.run(%{a: 1}) == {:ok, %{a: 1, b: 2, c: 4}}
  end

  test "StepModCodex fails modules" do
    assert StepModCodex.run(%{a: 1, fail: :b}) == {:error, %{a: 1, fail: :b}}
    assert StepModCodex.run(%{a: 1, fail: :c}) == {:error, %{a: 1, b: 2, fail: :c}}
  end

  test "StepNestedModCodex calls nested module steps" do
    assert StepNestedModCodex.run([:a]) == {:ok, [:b, :c, :a]}
  end

  defmodule ErrorFnCodex do
    use Codex

    step :error

    def error(args) do
      {:error, :fail}
    end

    def call(_params, _opts) do
      {:ok, 0}
    end
  end

  test "ErrorFnCodex returns error after step" do
    assert ErrorFnCodex.run([:a]) ==   {:error, :fail}
  end
end
