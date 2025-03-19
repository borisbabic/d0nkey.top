defmodule FunctionComponents.EsportsBadges do
  @moduledoc "Small esports function components"
  use Phoenix.Component

  # attr :atoms, :list, required: true
  # def stuff(assigns) do
  #   ~H"""
  #     <div>
  #       <%= for atom <- @atoms do %>
  #         <div>
  #           <%= case atom do %>
  #             <% :foo -> %>
  #               <.foo />
  #             <% :bar -> %>
  #               <.bar />
  #           <% end %>
  #         </div>
  #       <% end %>
  #     </div>
  #   """
  # end

  attr :badges, :list, required: true

  def badges(assigns) do
    ~H"""
      <div class="columns is-multiline is-mobile is-text-overflow" style="margin: 0.5px">
        <%= for atom <- @badges do %>
          <div class="tw-p-0">
            <%= case Backend.Blizzard.get_region_identifier(atom) do %>
              <% {:ok, region} -> %>
                <.badge badge={region}/>
              <% _ -> %>
                <.badge badge={atom}/>
            <% end %>
          </div>
        <% end %>
      </div>
    """
  end

  attr :badge, :atom

  def badge(%{badge: badge}) when badge in [:AM, :US, :EU, :AP, :CN] do
    new_badge = badge |> to_string() |> String.downcase() |> String.to_existing_atom()
    badge(%{badge: new_badge})
  end

  def badge(%{badge: badge}) do
    apply(__MODULE__, badge, [%{}])
  end

  def us(assigns) do
    ~H"""
      <.am />
    """
  end

  def am(assigns) do
    ~H"""
    <.base_badge text="Americas" class="tw-bg-[color:--color-americas] tw-text-gray-200 " />
    """
  end

  def ap(assigns) do
    ~H"""
    <.base_badge text="Asia-Pacific" class="tw-bg-[color:--color-asia] tw-text-gray-200 " />
    """
  end

  def eu(assigns) do
    ~H"""
    <.base_badge text="Europe" class="tw-bg-[color:--color-europe] tw-text-gray-200 " />
    """
  end

  def cn(assigns) do
    ~H"""
    <.base_badge text="China" class="tw-bg-[color:--color-china] tw-text-gray-200 " />
    """
  end

  def standard(assigns) do
    ~H"""
    <.base_badge text="Standard" class="tw-bg-[color:--color-standard] tw-text-gray-200 " />
    """
  end

  def wild(assigns) do
    ~H"""
    <.base_badge text="Wild" class="tw-bg-[color:--color-wild] tw-text-gray-200 "/>
    """
  end

  def twist(assigns) do
    ~H"""
    <.base_badge text="Twist" class="tw-bg-[color:--color-twist] tw-text-gray-200 "/>
    """
  end

  def battlegrounds(assigns) do
    ~H"""
    <.base_badge text="Battlegrounds" class="tw-bg-[color:--color-battlegrounds] tw-text-gray-200 "/>
    """
  end

  def bo5(assigns) do
    ~H"""
    <.base_badge text="Bo5" class="tw-bg-blue-500 tw-text-black"/>
    """
  end

  def bo3(assigns) do
    ~H"""
    <.base_badge text="Bo3" class="tw-bg-yellow-500 tw-text-black"/>
    """
  end

  def bo1(assigns) do
    ~H"""
    <.base_badge text="Bo1" class="tw-bg-orange-500 tw-text-black"/>
    """
  end

  def bo7(assigns) do
    ~H"""
    <.base_badge text="Bo7" class="tw-bg-red-500 tw-text-black"/>
    """
  end

  def open(assigns) do
    ~H"""
    <.base_badge text="Open" class="tw-bg-green-700 tw-text-black"/>
    """
  end

  def closed(assigns) do
    ~H"""
    <.base_badge text="Closed" class="tw-bg-red-700 tw-text-black"/>
    """
  end

  def team(assigns) do
    ~H"""
    <.base_badge text="Team" class="tw-bg-purple-500 tw-text-black"/>
    """
  end

  def solo(assigns) do
    ~H"""
    <.base_badge text="Solo" class="tw-bg-pink-500 tw-text-black"/>
    """
  end

  def free(assigns) do
    ~H"""
    <.base_badge text="Free" class="tw-bg-green-200 tw-text-black"/>
    """
  end

  def paid(assigns) do
    ~H"""
    <.base_badge text="Paid" class="tw-bg-red-200 tw-text-black"/>
    """
  end

  # def bo3_badge(assigns) do
  #   ~H"""
  #   <span class="bg-blue-100 text-blue-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-sm dark:bg-blue-900 dark:text-blue-300">Bo3</span>
  #   """
  # end
  # def bo1_badge(assigns) do
  #   ~H"""
  #   <span class="bg-red-100 text-red-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-sm dark:bg-red-900 dark:text-red-300">Bo1</span>
  #   """
  # end

  # def open_decklist_badge(assigns) do
  #   ~H"""
  #   <span class="bg-green-100 text-green-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-sm dark:bg-green-900 dark:text-green-300">Open Decklist</span>
  #   """
  # end
  # def closed_decklist_badge(assigns) do
  #   ~H"""
  #   <span class="bg-yellow-100 text-yellow-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-sm dark:bg-yellow-900 dark:text-yellow-300">Closed Decklist</span>
  #   """
  # end

  attr :text, :string, required: true
  attr :class, :string, default: ""

  def base_badge(assigns) do
    ~H"""
    <span class={"tw-text-xs tw-font-medium tw-me-2 tw-px-2.5 tw-py-0.5 tw-rounded-sm #{@class}"}>
      <%= @text %>
    </span>
    """
  end
end
