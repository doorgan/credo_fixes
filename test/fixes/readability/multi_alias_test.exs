defmodule CredoFixesTest.Fixes.Readability.MultiAlias do
  use ExUnit.Case, async: true

  import CredoFixes.Test

  cases = [
    %{
      name: ~S(expand multi-alias),
      original: ~S'''
      alias Foo.{Bar, Baz.Qux}
      ''',
      expected: ~S'''
      alias Foo.Bar
      alias Foo.Baz.Qux
      '''
    },
    %{
      name: ~S(no change expected),
      original: "asdf",
      expected: "asdf"
    },
    %{
      name: ~S(preserve comments),
      original: ~S'''
      # Multi alias example
      alias Foo.{ # Opening the multi alias
        Bar, # Here is Bar
        # Here come the Baz
        Baz.Qux # With a Qux!
        }
      # End of the demo :)
      ''',
      expected: ~S'''
      # Multi alias example
      # Opening the multi alias
      # Here is Bar
      alias Foo.Bar
      # Here come the Baz
      # With a Qux!
      alias Foo.Baz.Qux
      # End of the demo :)
      '''
    },
    %{
      name: ~S(does not misplace comments above or below),
      original: ~S'''
      # A
      :a
      alias Foo.{Bar, Baz,
      Qux, Quux}
      :b # B
      ''',
      expected: ~S'''
      # A
      :a
      alias Foo.Bar
      alias Foo.Baz
      alias Foo.Qux
      alias Foo.Quux
      :b # B
      '''
    }
  ]

  test_fixes(CredoFixes.Fixes.Readability.MultiAlias, cases)
end
