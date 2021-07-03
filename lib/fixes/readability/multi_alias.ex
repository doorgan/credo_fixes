defmodule CredoFixes.Fixes.Readability.MultiAlias do
  @behaviour CredoFixes.Fixer

  @impl true
  def get_fixes(source) do
    ast = Sourceror.parse_string!(source)

    {_, fixes} = Macro.postwalk(ast, [], &expand_alias/2)

    fixes
  end

  defp expand_alias(
         {:alias, alias_meta, [{{:., _, [left, :{}]}, call_meta, right}]} = quoted,
         fixes
       ) do
    {_, _, base_segments} = left
    leading_comments = alias_meta[:leading_comments] || []
    trailing_comments = call_meta[:trailing_comments] || []

    aliases =
      right
      |> Enum.map(&segments_to_alias(base_segments, &1))
      |> put_leading_comments(leading_comments)
      |> put_trailing_comments(trailing_comments)

    fix = %{
      range: Sourceror.get_range(quoted),
      change: Sourceror.to_string({:__block__, [], aliases})
    }

    {quoted, [fix | fixes]}
  end

  defp expand_alias(quoted, fixes), do: {quoted, fixes}

  defp segments_to_alias(base_segments, {_, meta, segments}) do
    {:alias, meta, [{:__aliases__, [], base_segments ++ segments}]}
  end

  defp put_leading_comments([first | rest], comments) do
    [Sourceror.prepend_comments(first, comments) | rest]
  end

  defp put_trailing_comments(list, comments) do
    case List.pop_at(list, -1) do
      {nil, list} ->
        list

      {last, list} ->
        last = {:__block__, [trailing_comments: comments], [last]}

        list ++ [last]
    end
  end
end
