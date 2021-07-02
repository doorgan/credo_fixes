defmodule CredoFixes.Fixes.Refactor.MapJoin do
  @behaviour CredoFixes.Fixer

  @impl true
  def get_fixes(source) do
    ast = Sourceror.parse_string!(source)

    {_, fixes} = Macro.prewalk(ast, [], &get_fix/2)

    Enum.reverse(fixes)
  end

  # TODO find a better way to do this, because there's a lot of
  # repetition the fixes can explode in complexity if they need to work over
  # several permutations of the same code

  # Enum.join(Enum.map(a, b), c)
  defp get_fix(
         {{:., _, [{:__aliases__, _, [:Enum]}, :join]}, join_meta,
          [{{:., _, [{:__aliases__, _, [:Enum]}, :map]}, map_meta, map_args}, joiner]} = ast,
         fixes
       ) do
    range = Sourceror.get_range(ast)

    quoted = {{:., [], [{:__aliases__, [], [:Enum]}, :map_join]}, join_meta, map_args ++ [joiner]}

    quoted =
      Sourceror.append_comments(
        quoted,
        map_meta[:leading_comments]
      )

    fix = %{
      change: Sourceror.to_string(quoted),
      range: range
    }

    {quoted, [fix | fixes]}
  end

  # Enum.map(a, b) |> Enum.join(c)
  defp get_fix(
         {:|>, pipe_meta,
          [
            {{:., _, [{:__aliases__, _, [:Enum]}, :map]}, map_meta, map_args},
            {{:., _, [{:__aliases__, _, [:Enum]}, :join]}, join_meta, joiner}
          ]} = ast,
         fixes
       ) do
    range = Sourceror.get_range(ast)

    quoted = {{:., [], [{:__aliases__, [], [:Enum]}, :map_join]}, map_meta, map_args ++ joiner}

    quoted =
      Sourceror.append_comments(
        quoted,
        pipe_meta[:leading_comments] ++ join_meta[:leading_comments]
      )

    fix = %{
      change: Sourceror.to_string(quoted),
      range: range
    }

    {quoted, [fix | fixes]}
  end

  # a |> Enum.map(b) |> Enum.join(c)
  defp get_fix(
         {:|>, pipe1_meta,
          [
            {:|>, pipe2_meta,
             [
               base_arg,
               {{:., _, [{:__aliases__, _, [:Enum]}, :map]}, map_meta, map_args}
             ]},
            {{:., _, [{:__aliases__, _, [:Enum]}, :join]}, join_meta, join_args}
          ]} = ast,
         fixes
       ) do
    range = Sourceror.get_range(ast)

    args = map_args ++ join_args

    map_meta =
      Keyword.update(map_meta, :leading_comments, [], fn comments ->
        pipe2_meta[:leading_comments] ++ comments ++ join_meta[:leading_comments]
      end)
      |> Keyword.delete(:closing)

    quoted =
      {:|>, pipe1_meta,
       [
         base_arg,
         {{:., [], [{:__aliases__, [], [:Enum]}, :map_join]}, map_meta, args}
       ]}

    fix = %{
      change: Sourceror.to_string(quoted),
      range: range
    }

    {quoted, [fix | fixes]}
  end

  # Enum.join(a |> Enum.map(b), c)
  defp get_fix(
         {{:., _, [{:__aliases__, _, [:Enum]}, :join]}, join_meta,
          [
            {:|>, pipe_meta,
             [
               base_arg,
               {{:., map_alias_meta, [{:__aliases__, _, [:Enum]}, :map]}, map_meta, map_args}
             ]},
            joiner
          ]} = ast,
         fixes
       ) do
    range = Sourceror.get_range(ast)

    joiner = Sourceror.prepend_comments(joiner, pipe_meta[:trailing_comments])

    args = [base_arg] ++ map_args ++ [joiner]

    meta =
      Keyword.update(join_meta, :leading_comments, [], fn comments ->
        comments ++
          map_alias_meta[:leading_comments] ++
          pipe_meta[:leading_comments] ++ map_meta[:leading_comments]
      end)
      |> Keyword.delete(:closing)

    quoted = {{:., [], [{:__aliases__, [], [:Enum]}, :map_join]}, meta, args}

    fix = %{
      change: Sourceror.to_string(quoted),
      range: range
    }

    {quoted, [fix | fixes]}
  end

  defp get_fix(ast, fixes) do
    {ast, fixes}
  end
end
