defmodule CredoFixes.Fixes.Refactor.NegatedConditionsInUnless do
  @behaviour CredoFixes.Fixer

  @impl true
  def get_fixes(source) do
    ast = Sourceror.parse_string!(source)

    {_, fixes} =
      Macro.prewalk(ast, [], fn
        {:unless, meta, conditions} = quoted, fixes ->
          case conditions do
            [{negation, _, [first]} | rest] when negation in [:!, :not] ->
              fix = %{
                change: Sourceror.to_string({:if, meta, [first | rest]}),
                range: Sourceror.get_range(quoted)
              }

              {quoted, [fix | fixes]}

            _ ->
              {quoted, fixes}
          end

        quoted, fixes ->
          {quoted, fixes}
      end)

    Enum.reverse(fixes)
  end
end
