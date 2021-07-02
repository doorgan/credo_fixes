defmodule CredoFixes.Fixes.Refactor.NegatedConditionsWithElse do
  @behaviour CredoFixes.Fixer

  @impl true
  def get_fixes(source) do
    ast = Sourceror.parse_string!(source)

    {_, fixes} =
      Macro.prewalk(ast, [], fn
        {:if, meta, conditions} = quoted, fixes ->
          with [{negation, _, [first]} | rest] when negation in [:!, :not] <- conditions,
               {[{do_start, do_block}, {else_start, else_block}], rest} <- List.pop_at(rest, -1) do
            blocks = [
              {do_start, else_block},
              {else_start, do_block}
            ]

            args = [first | rest ++ [blocks]]

            new_ast = {:if, meta, args}

            fix = %{
              change: Sourceror.to_string(new_ast),
              range: Sourceror.get_range(quoted)
            }

            {quoted, [fix | fixes]}
          else
            _ -> {quoted, fixes}
          end

        quoted, fixes ->
          {quoted, fixes}
      end)

    Enum.reverse(fixes)
  end
end
