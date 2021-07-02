defmodule CredoFixesTest.Fixes.Readability.AliasOrder do
  use ExUnit.Case, async: true

  import CredoFixes.Test

  cases = [
    %{
      name: "orders aliases",
      original: ~S"""
      defmodule Test do
        alias J
        alias C
        # Comment for B
        alias B
        alias A
        alias H
      end
      """,
      expected: ~S"""
      defmodule Test do
        alias A
        # Comment for B
        alias B
        alias C
        alias H
        alias J
      end
      """
    },
    %{
      name: "with other stuff in between",
      original: ~S"""
      defmodule Test do
        alias J
        alias C
        @foo bar
        alias B
        alias A
        alias H
      end
      """,
      expected: ~S"""
      defmodule Test do
        alias C
        alias J
        @foo bar
        alias A
        alias B
        alias H
      end
      """
    },
    %{
      name: "with multi aliases",
      original: ~S"""
      defmodule Test do
        alias C
        alias J.{F, B}
        alias J.{A}
        alias A
        alias B
        alias H
      end
      """,
      expected: ~S"""
      defmodule Test do
        alias A
        alias B
        alias C
        alias H
        alias J.{A}
        alias J.{F, B}
      end
      """
    }
  ]

  test_fixes(CredoFixes.Fixes.Readability.AliasOrder, cases)
end
