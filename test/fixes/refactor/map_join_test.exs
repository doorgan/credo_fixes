defmodule CredoFixesTest.Fixes.Refactor.MapJoin do
  use ExUnit.Case, async: true

  import CredoFixes.Test

  cases = [
    %{
      name: "map piped into join",
      original: ~S"""
      Enum.map(a, b)
      |> Enum.join(c)
      """,
      expected: ~S"""
      Enum.map_join(a, b, c)
      """
    },
    %{
      name: "join with nested map",
      original: ~S"""
      Enum.join(Enum.map(a, b), c)
      """,
      expected: ~S"""
      Enum.map_join(a, b, c)
      """
    },
    %{
      name: "join with piped map inside",
      original: ~S"""
      Enum.join(a |> Enum.map(b), c)
      """,
      expected: ~S"""
      Enum.map_join(a, b, c)
      """
    },
    %{
      name: "join with piped map inside and comments",
      original: ~S"""
      Enum.join( # a
      a # b
      |> # c
      Enum.map( # d
      b # e
      ), # f
      c # g
      )
      """,
      expected: ~S"""
      # a
      # b
      # c
      # d
      Enum.map_join(
        a,
        # e
        b,
        # f
        # g
        c
      )
      """
    },
    %{
      name: "join with nested map and comments",
      original: ~S"""
      Enum # a
      . # b
      join( # c
      Enum # d
      . # e
      map( # f
      a, # g
      b # h
      ), # i
      c # j
      )
      """,
      expected: ~S"""
      # a
      # b
      # c
      # d
      # e
      # f
      Enum.map_join(
        # g
        a,
        # h
        b,
        # i
        # j
        c
      )
      """
    }
  ]

  test_fixes(CredoFixes.Fixes.Refactor.MapJoin, cases)
end
