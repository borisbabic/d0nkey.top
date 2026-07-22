defmodule BackendWeb.PageView do
  use BackendWeb, :view
  import FunctionComponents.MiscComponents

  def api_doc_metric(assigns) do
    ~H"""
    <div class="tw-rounded-lg tw-border tw-border-slate-800 tw-bg-slate-950/50 tw-p-4">
      <code class="tw-text-xs tw-text-cyan-300">{@name}</code>
      <p class="tw-mt-2 tw-text-xs tw-leading-5 tw-text-slate-500">{@description}</p>
    </div>
    """
  end

  def api_doc_endpoint(assigns) do
    ~H"""
    <div>
      <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-3">
        <span class="tw-rounded-md tw-bg-emerald-500/15 tw-px-2.5 tw-py-1 tw-text-xs tw-font-bold tw-text-emerald-300">{@method}</span>
        <code class="tw-break-all tw-text-base md:tw-text-lg tw-text-white">{@path}</code>
      </div>
      <p class="tw-mt-3 tw-text-slate-400">{@summary}</p>
    </div>
    """
  end

  def api_doc_parameters(assigns) do
    ~H"""
    <div class="tw-mt-4 tw-overflow-x-auto tw-rounded-xl tw-border tw-border-slate-800">
      <table class="tw-w-full tw-min-w-[640px] tw-text-left tw-text-sm">
        <thead class="tw-bg-slate-900 tw-text-slate-300">
          <tr>
            <th class="tw-p-3">Parameter</th>
            <th class="tw-p-3">Type</th>
            <th class="tw-p-3">Description</th>
          </tr>
        </thead>
        <tbody class="tw-divide-y tw-divide-slate-800 tw-bg-slate-950/40">
          <tr :for={{name, type, description} <- @rows}>
            <td class="tw-p-3 tw-align-top"><code class="tw-text-cyan-300">{name}</code></td>
            <td class="tw-p-3 tw-align-top tw-text-slate-500">{type}</td>
            <td class="tw-p-3 tw-align-top tw-text-slate-400">{description}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
