[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  surface_inputs: ["{lib,test}/**/*.{ex,exs,sface}", "priv/catalogue/**/*.{ex,exs,sface}"],
  subdirectories: ["priv/*/migrations"]
]
