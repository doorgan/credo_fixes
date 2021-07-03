defmodule CredoFixes.Fixes.Readability.AliasOrder do
  @behaviour CredoFixes.Fixer

  @impl true
  def get_fixes(source) do
    ast = Sourceror.parse_string!(source)

    {_, fixes} =
      Macro.prewalk(ast, [], fn
        {:defmodule, _, [_, [{{_, _, [:do]}, {_, _, args}}]]} = quoted, fixes ->
          fixes = get_fixes_for_args(args) ++ fixes

          {quoted, fixes}

        quoted, fixes ->
          {quoted, fixes}
      end)

    fixes
  end

  defp get_fixes_for_args(args) do
    state = %{
      fixes: [],
      chunk: [],
      chunk_start: nil
    }

    %{fixes: fixes, chunk: chunk, chunk_start: chunk_start} =
      Enum.reduce(args, state, fn
        {:alias, _, _} = current, state ->
          state =
            if is_nil(state.chunk_start) do
              %{state | chunk_start: Sourceror.get_range(current).start}
            else
              state
            end

          %{state | chunk: [current | state.chunk]}

        _, state ->
          fixes =
            if fix = chunk_to_fix(state.chunk, state.chunk_start) do
              [fix | state.fixes]
            else
              state.fixes
            end

          %{state | fixes: fixes, chunk: [], chunk_start: nil}
      end)

    if fix = chunk_to_fix(chunk, chunk_start) do
      [fix | fixes]
    else
      fixes
    end
  end

  defp chunk_to_fix([], _), do: nil

  defp chunk_to_fix([last | _] = chunk, chunk_start) do
    chunk = Enum.reverse(chunk)
    chunk_end = Sourceror.get_range(last).end

    sorted_chunk = chunk |> Enum.sort_by(&Macro.to_string/1)

    if chunk != sorted_chunk do
      %{
        range: %{start: chunk_start, end: chunk_end},
        change: Sourceror.to_string({:__block__, [], sorted_chunk})
      }
    end
  end
end
