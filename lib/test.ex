defmodule CredoFixes.Test do
  @moduledoc """
  Helpers to test fixes
  """

  @type fix_case :: %{
          name: String.t(),
          original: String.t(),
          expected: String.t()
        }

  @doc """
  Generates test cases for a fix module from a list of fix cases.

  A fix case is a map with `:name`, `:original` and `:expected` keys,
  representing the test name, the original source code annd what the fix should
  produce.

  The fix module must implement the `CredoFixes.Fixer` behaviour. The
  `get_fixes` function will be called with the original source code, and the
  resulting fixes will then be applied to it with `Sourceror.patch_string/2`.

  Both the resulting source code and the expected source code will have their
  trailing newlines trimmed to avoid issues with sigils like `~S`
  """
  defmacro test_fixes(module, cases) do
    quote location: :keep, bind_quoted: [module: module, cases: cases] do
      for test_case <- cases do
        @case test_case
        @module module

        test @case.name do
          fixes = @module.get_fixes(@case.original)
          expected = String.trim_trailing(@case.expected)

          actual =
            @case.original
            |> Sourceror.patch_string(fixes)
            |> String.trim_trailing()

          assert expected == actual
        end
      end
    end
  end
end
