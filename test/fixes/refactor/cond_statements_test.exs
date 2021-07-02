defmodule CredoFixesTest.Fixes.Refactor.CondStatements do
  use ExUnit.Case, async: true

  import CredoFixes.Test

  cases = [
    %{
      name: "replaces cond with an if",
      original: ~S"""
      cond do # Ahh
      something = foo? # Hello
      -> # Was it you
      bar # Who rang
      true # The bell
      -> # Of
      baz # Awakening?
      end
      """,
      expected: ~S"""
      # Ahh
      if something = foo? do
        # Hello
        # Was it you
        # Who rang
        bar
      else
        # The bell
        # Of
        # Awakening?
        baz
      end
      """
    },
    %{
      name: "fixes only a range",
      original: ~S"""
      defmodule Foo do

        def bar do
          cond do
            _ok ->
              :ok
            something -> # heh
              elsewhere
          end
        end
      end
      """,
      expected: ~S"""
      defmodule Foo do

        def bar do
          if something do
            # heh
            elsewhere
          else
            :ok
          end
        end
      end
      """
    }
  ]

  test_fixes(CredoFixes.Fixes.Refactor.CondStatements, cases)
end
