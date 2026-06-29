defmodule BackendWeb.StatsHTML do
  use BackendWeb, :html
  use PhoenixHTMLHelpers

  import FunctionComponents.MiscComponents, only: [section_block: 1, filter_row: 1, stat_card: 1, alert: 1]
  embed_templates "stats_html/*"
end
