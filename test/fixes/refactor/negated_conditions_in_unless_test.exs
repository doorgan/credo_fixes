defmodule CredoFixesTest.Fixes.Refactor.NegatedConditionsInUnless do
  use ExUnit.Case, async: true

  import CredoFixes.Test

  cases = [
    %{
      name: "negated unless",
      original: ~S"""
      unless !allowed? do # 1
        proceed_as_planned() # 2
      end
      """,
      expected: ~S"""
      # 1
      if allowed? do
        # 2
        proceed_as_planned()
      end
      """
    },
    %{
      name: "",
      original: ~S"""
      unless not allowed? do # 1
        proceed_as_planned() # 2
      end
      """,
      expected: ~S"""
      # 1
      if allowed? do
        # 2
        proceed_as_planned()
      end
      """
    }
  ]

  test_fixes(CredoFixes.Fixes.Refactor.NegatedConditionsInUnless, cases)
end
