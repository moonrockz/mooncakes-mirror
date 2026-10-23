# Vendored MoonBit modules

These modules are copies of published mooncakes.io packages. They are
patched so that they build with the current MoonBit toolchain. The root
`moon.work` file adds them as workspace members, so `moon` uses these copies
in place of the registry versions.

| Module | Version | Archive SHA-256 |
| --- | --- | --- |
| `Yoorkin/rabbit-tea` | 0.10.11 | `4a562500f2ad43a84f8632ad90b4ad500bb3638b8bb11d49f181de2c7081c4bf` |
| `rami3l/js-ffi` | 0.4.0 | `4024d402739edab60f6c9a09a3fccaed699f9b8865aae834bb7b6303966a95e8` |

`Yoorkin/rabbit-tea` is deprecated upstream in favor of
`moonbit-community/rabbita`, and neither module has a newer release. Remove
this directory when the site moves to `rabbita`.

## Patches

- `moon.mod.json` / `moon.pkg.json` migrated to `moon.mod` / `moon.pkg`
  (`moon fmt`). Current `moon` rejects the JSON manifests, also in
  dependencies.
- `js-ffi/src/js/error.mbt`: `pub suberror Error_ Value` changed to the
  enum form `pub suberror Error_ { Error_(Value) }`. The short form no
  longer parses.
- `js-ffi/src/js/{object,value,object_test}.mbt`: `.inner()` changed to
  `.0`. The compiler no longer generates `inner()` for tuple structs
  (error `[4015] Type Object has no method inner`).
- `rabbit-tea/src/url/url.mbt`: `@strconv.parse_int(port.to_string())`
  changed to `@string.parse_int(port)`. `moonbitlang/core/strconv` no
  longer has `parse_int`.
