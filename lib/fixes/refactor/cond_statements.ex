defmodule CredoFixes.Fixes.Refactor.CondStatements do
  @behaviour CredoFixes.Fixer

  @impl true
  def get_fixes(source) do
    ast = Sourceror.parse_string!(source)

    {_, fixes} =
      Macro.prewalk(ast, [], fn
        {:cond, meta, [arguments]} = quoted, fixes ->
          [{_do_block, conditions}] = arguments

          if Enum.any?(conditions, &always_matching?/1) do
            fix = %{
              change: fix_ast(conditions, meta) |> Sourceror.to_string(),
              range: Sourceror.get_range(quoted)
            }

            {quoted, [fix | fixes]}
          else
            {quoted, fixes}
          end

        quoted, fixes ->
          {quoted, fixes}
      end)

    Enum.reverse(fixes)
  end

  defp fix_ast(conditions, meta) do
    {_, {else_clause, if_clause}} =
      Macro.postwalk(conditions, {nil, nil}, fn
        {:->, _, _} = clause, {if_clause, else_clause} ->
          if always_matching?(clause) do
            {clause, {clause, else_clause}}
          else
            {clause, {if_clause, clause}}
          end

        quoted, acc ->
          {quoted, acc}
      end)

    {:->, else_stab_meta, [_, else_block]} = else_clause
    {:->, if_stab_meta, [[if_condition], if_block]} = if_clause

    else_block = Sourceror.prepend_comments(else_block, else_stab_meta[:leading_comments])
    if_block = Sourceror.prepend_comments(if_block, if_stab_meta[:leading_comments])

    {:if, meta,
     [
       if_condition,
       [make_block(do: if_block), make_block(else: else_block)]
     ]}
  end

  defp make_block([{key, block}]) do
    {{:__block__, [], [key]}, block}
  end

  defp always_matching?(clause)

  defp always_matching?({:->, _meta, [[{_, _, [true]}], _args]}), do: true

  defp always_matching?({:->, _meta, [[{name, _meta2, nil}], _args]}) when is_atom(name) do
    name |> to_string |> String.starts_with?("_")
  end

  defp always_matching?(_), do: false
end
