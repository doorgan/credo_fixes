# CredoFixes

A collection of functions that generate Sourceror patches for Credo issues.

This is meant to be used as a reference for other people to adapt to their own
tools and scripts.

Fixer modules are located in the `lib/fixes` folder, and they expose a
`get_fixes/1` function that takes the source code and returns a list of
Sourceror fixes.

Keep in mind that the fixes are produced **for the whole source code**, not at a
particular location. You will need to adapt them for that, but it should be as
simple as locating the pattern at a given line and column by checking the node
metadata, and only then generating the patches.

While Sourceror is able to print the whole modified AST, it does so by using the
Elixir formatter, which would mess up the code of people not using it. For this
reason the functions in this repo return patches to be applied with
`Sourceror.patch_string/2`. By limiting ourselves to changing only what needs to
be changed, we can mitigate this issue.

In the future it would be nice to have an alternative AST printer that preserves
the original formatting. If you want to help with this, please check [this
Sourceror issue](https://github.com/doorgan/sourceror/issues/15).
