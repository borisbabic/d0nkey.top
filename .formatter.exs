[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  surface_inputs: ["{lib,test}/**/*.{ex,exs,sface}", "priv/catalogue/**/*.{ex,exs,sface}"],
  plugins: [Quokka],
  quokka: [
    only: [
      :nums_with_underscores,
      :pipes,
      :inefficient_functions,
      :single_node
    ]
  ],
  subdirectories: ["priv/*/migrations"]
]
