defmodule BackendWeb.RevealHTML do
  use BackendWeb, :html

  use PhoenixHTMLHelpers

  embed_templates "reveal_html/*"
end
