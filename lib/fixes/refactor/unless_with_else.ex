defmodule CredoFixes.Fixes.Refactor.UnlessWithElse do
  @behaviour CredoFixes.Fixer

  @impl true
  def get_fixes(source) do
    ast = Sourceror.parse_string!(source)

    {_, fixes} =
      Macro.prewalk(ast, [], fn
        {:unless, meta, arguments} = quoted, fixes ->
          case get_else_block(arguments) do
            nil ->
              {quoted, fixes}

            {{_, else_meta, _}, else_block} ->
              {{_, do_meta, _}, do_block} = get_do_block(arguments)

              {_, arguments} = List.pop_at(arguments, -1)

              new_ast =
                {:if, meta,
                 arguments ++
                   [
                     [
                       {{:__block__, else_meta, [:do]}, else_block},
                       {{:__block__, do_meta, [:else]}, do_block}
                     ]
                   ]}

              fix = %{
                change: Sourceror.to_string(new_ast),
                range: Sourceror.get_range(quoted)
              }

              {quoted, [fix | fixes]}
          end

        quoted, fixes ->
          {quoted, fixes}
      end)

    Enum.reverse(fixes)
  end

  defp get_do_block(arguments) do
    get_block(arguments, :do)
  end

  defp get_else_block(arguments) do
    get_block(arguments, :else)
  end

  defp get_block(arguments, key) do
    case List.last(arguments) do
      list when is_list(list) ->
        Enum.find(list, &match?({{:__block__, _, [^key]}, _}, &1))

      _ ->
        nil
    end
  end
end
