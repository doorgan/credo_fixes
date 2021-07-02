defmodule CredoFixes.Fixer do
  @callback get_fixes(String.t()) :: [Sourceror.patch()]
end
