defmodule CredoFixesTest.Fixes.Refactor.NegatedConditionsWithElse do
  use ExUnit.Case, async: true

  import CredoFixes.Test

  cases = [
    %{
      name: "negated if without else remains unchanged",
      original: ~S"""
      if !allowed? do
        proceed_as_planned()
      end
      """,
      expected: ~S"""
      if !allowed? do
        proceed_as_planned()
      end
      """
    },
    %{
      name: "negated if with not",
      original: ~S"""
      if not allowed? do # 1
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
    },
    %{
      name: "negated if with bang",
      original: ~S"""
      if !allowed? do # 1
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

  test_fixes(CredoFixes.Fixes.Refactor.NegatedConditionsWithElse, cases)
end
