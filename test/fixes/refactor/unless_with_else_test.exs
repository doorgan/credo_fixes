defmodule CredoFixesTest.Fixes.Refactor.UnlessWithElse do
  use ExUnit.Case, async: true

  import CredoFixes.Test

  cases = [
    %{
      name: "negated if without else remains unchanged",
      original: ~S"""
      unless allowed? do # 1
        raise "Not allowed!" # 2
      else # 3
        proceed_as_planned() # 4
      end
      """,
      expected: ~S"""
      # 1
      # 3
      if allowed? do
        # 4
        proceed_as_planned()
      else
        # 2
        raise "Not allowed!"
      end
      """
    }
  ]

  test_fixes(CredoFixes.Fixes.Refactor.UnlessWithElse, cases)
end
