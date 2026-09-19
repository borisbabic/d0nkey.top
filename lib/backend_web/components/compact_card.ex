defmodule Components.CompactCard do
  @moduledoc """
  Displays a card concisely with pure cropped artwork in a squarish/rounded container.
  - Class-colored border (half/half diagonal gradient for dual-class cards).
  - Upper left: Mana cost (blue crystal).
  - Bottom left: Attack (amber sword badge, for minions and weapons).
  - Bottom right: Health or durability (checking health first; red for minions, slate for weapons/locations).
  - Upper right: Count in deck if > 1, or gold star ★ for Legendaries.
  - Subtle card type indicator glyph for non-minion types (Spell, Weapon, Location, Hero).
  - Hover tooltip displaying full card render.
  """

  use BackendWeb, :surface_component
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.CardBag
  alias Backend.Hearthstone.Deck
  alias Backend.HearthstoneJson

  defguardp long_value?(val)
            when (is_integer(val) and val >= 10) or (is_binary(val) and byte_size(val) >= 2)

  prop(card, :map, required: true)
  prop(count, :integer, default: 1)
  prop(deck, :map, default: %{})
  prop(use_deck_card_cost, :boolean, default: true)
  prop(sideboarded_in, :boolean, default: false)
  prop(disable_link, :boolean, default: false)
  prop(shape, :string, default: "squarish")
  prop(size, :string, default: "md")
  prop(show_tooltip, :boolean, default: true)
  prop(mode, :string, default: "card_top")

  data(mana_cost, :integer)
  data(attack, :integer)
  data(health_or_durability, :integer)
  data(legendary?, :boolean)
  data(card_type, :string)
  data(type_name, :string)
  data(art_url, :string)
  data(card_url, :string)
  data(border_style, :string)
  data(image_id, :string)
  data(extra_layers, :list)
  data(slot_style, :string)
  data(card_top_size_style, :string)
  data(card_top_img_style, :string)
  data(card_top_mask_style, :string)

  def render(assigns) do
    card = assigns[:card]
    deck = assigns[:deck] || %{}
    use_deck_cost = Map.get(assigns, :use_deck_card_cost, true)
    mana_cost = cost(card, use_deck_cost, deck)

    attack =
      case Map.get(card, :attack) do
        a when is_integer(a) -> a
        _ -> nil
      end

    health_or_durability = Card.durability_or_health(card)
    count = assigns[:count] || 1
    is_legendary = legendary?(card)
    size = assigns[:size] || "md"
    shape = assigns[:shape] || "squarish"
    mode = assigns[:mode] || "card_top"
    show_tooltip = Map.get(assigns, :show_tooltip, true)
    card_type = Card.type(card)
    type_name = type_name(card_type)
    {art_url, card_url} = image_urls(card)
    border_style = border_style(card)
    image_id = "compact-card-preview-#{System.unique_integer([:positive])}"
    extra_layers = extra_layers(count)
    slot_style = slot_size_style(size, mode)
    card_top_size = card_top_size_style(size)
    card_top_img = card_top_img_style(size)
    card_top_mask = card_top_mask_style(size)

    assigns =
      assigns
      |> assign(
        count: count,
        size: size,
        shape: shape,
        mode: mode,
        show_tooltip: show_tooltip,
        mana_cost: mana_cost,
        attack: attack,
        health_or_durability: health_or_durability,
        legendary?: is_legendary,
        card_type: card_type,
        type_name: type_name,
        art_url: art_url,
        card_url: card_url,
        border_style: border_style,
        image_id: image_id,
        extra_layers: extra_layers,
        slot_style: slot_style,
        card_top_size_style: card_top_size,
        card_top_img_style: card_top_img,
        card_top_mask_style: card_top_mask
      )

    ~F"""
    <div
      class="tw-relative tw-inline-block tw-shrink-0"
      style={@slot_style}
      onmouseenter={if @show_tooltip, do: "window.position_card_tooltip && window.position_card_tooltip(event, '#{@image_id}')", else: nil}
      onmousemove={if @show_tooltip, do: "window.position_card_tooltip && window.position_card_tooltip(event, '#{@image_id}')", else: nil}
      onmouseleave={if @show_tooltip, do: "set_display('#{@image_id}', 'none')", else: nil}
    >
      <a
        href={if @disable_link, do: "javascript:;", else: ~p"/card/#{Card.dbf_id(@card)}"}
        aria-label={"#{@count}x #{@card.name} (#{@mana_cost} mana)"}
        title={card_title(@card, @count, @type_name)}
        class={["tw-block tw-w-full tw-h-full tw-relative tw-group tw-transition-transform hover:tw-scale-105 hover:tw-z-20", "has-no-pointer-events": @disable_link]}
      >
        {#if @mode == "card_top"}
          <!-- Stacked Card(s) Underneath for Multiple Copies (Card Top Mode) -->
          {#for layer <- @extra_layers}
            <div
              class="tw-absolute tw-overflow-hidden tw-pointer-events-none tw-rounded-[4px]"
              style={stack_card_top_style(layer, @size) <> "; " <> @card_top_size_style <> "; " <> @card_top_mask_style}
            >
              <img
                src={@card_url}
                alt=""
                class="tw-pointer-events-none tw-select-none"
                style={@card_top_img_style}
                loading="lazy"
              />
            </div>
          {/for}

          <!-- Front Card Top (Cut off below rarity gem with smooth fade) -->
          <div
            class={[
              "tw-absolute tw-left-0 tw-bottom-0 tw-z-10 tw-overflow-hidden tw-rounded-[4px]",
              @sideboarded_in && "tw-ring-2 tw-ring-dashed tw-ring-purple-400 tw-rounded-md"
            ]}
            style={@card_top_size_style <> "; " <> @card_top_mask_style}
          >
            <img
              src={@card_url}
              alt={@card.name}
              class="tw-pointer-events-none tw-select-none"
              style={@card_top_img_style}
              loading="lazy"
            />
          </div>
        {#else}
          <!-- Stacked Card(s) Underneath for Multiple Copies (Cropped Art Mode) -->
          {#for layer <- @extra_layers}
            <div
              class={[
                container_size_classes(@size),
                shape_classes(@shape),
                "tw-absolute tw-p-[1.5px] tw-box-border tw-shadow-sm tw-bg-slate-900 tw-pointer-events-none",
                stack_brightness_class(layer)
              ]}
              style={stack_card_style(@border_style, layer, @size)}
            >
              <!-- Art Container -->
              <div class={[
                inner_shape_classes(@shape),
                "tw-w-full tw-h-full tw-overflow-hidden tw-relative tw-bg-slate-950"
              ]}>
                <img
                  src={@art_url}
                  alt=""
                  class="tw-w-full tw-h-full tw-object-cover tw-scale-[1.45] tw-select-none tw-pointer-events-none"
                  style="transform: scale(1.45);"
                  loading="lazy"
                />
              </div>
            </div>
          {/for}

          <!-- Front Card Container with Class Border (Cropped Art Mode) -->
          <div
            class={[
              container_size_classes(@size),
              shape_classes(@shape),
              "tw-absolute tw-left-0 tw-bottom-0 tw-z-10 tw-p-[1.5px] tw-box-border tw-shadow-[0_0_8px_rgba(0,0,0,0.7)] tw-bg-slate-900",
              @sideboarded_in && "tw-ring-2 tw-ring-dashed tw-ring-purple-400"
            ]}
            style={@border_style}
          >
            <!-- Art Container -->
            <div class={[
              inner_shape_classes(@shape),
              "tw-w-full tw-h-full tw-overflow-hidden tw-relative tw-bg-slate-950"
            ]}>
              <img
                src={@art_url}
                alt={@card.name}
                class="tw-w-full tw-h-full tw-object-cover tw-scale-[1.45] tw-select-none tw-pointer-events-none"
                style="transform: scale(1.45);"
                loading="lazy"
              />
            </div>

            <!-- Top-Left: Mana Cost -->
            <span
              title={"Mana Cost: #{@mana_cost}"}
              class={[
                "hearthstone-stat-number tw-absolute tw-z-20",
                number_size_classes(@size, @mana_cost)
              ]}
              style={number_pos_style("top-left", @size, @mana_cost)}
            >
              {@mana_cost}
            </span>

            <!-- Bottom-Left: Attack (Minions & Weapons) -->
            <span
              :if={@attack != nil}
              title={"Attack: #{@attack}"}
              class={[
                "hearthstone-stat-number tw-absolute tw-z-20",
                number_size_classes(@size, @attack)
              ]}
              style={number_pos_style("bottom-left", @size, @attack)}
            >
              {@attack}
            </span>

            <!-- Bottom-Right: Health or Durability -->
            <span
              :if={@health_or_durability != nil}
              title={if @card_type in ["WEAPON", "LOCATION"], do: "Durability: #{@health_or_durability}", else: "Health: #{@health_or_durability}"}
              class={[
                "hearthstone-stat-number tw-absolute tw-z-20",
                number_size_classes(@size, @health_or_durability)
              ]}
              style={number_pos_style("bottom-right", @size, @health_or_durability)}
            >
              {@health_or_durability}
            </span>

            <!-- Top-Right: Legendary Star (Only on Legendaries) -->
            <span
              :if={@legendary?}
              title="Legendary"
              class="tw-absolute tw-z-20 tw-text-amber-400 tw-select-none"
              style={legend_star_style(@size)}
            >
              ★
            </span>
          </div>
        {/if}
      </a>

      <!-- Hover Tooltip Preview -->
      <div
        :if={@show_tooltip}
        id={@image_id}
        class="tw-fixed tw-z-[9999] tw-pointer-events-none tw-shadow-2xl tw-rounded-lg"
        style={"display: none; background-image: url('#{@card_url}'); background-size: 256px 384px; width: 256px; height: 384px; background-repeat: no-repeat;"}
      />
    </div>
    """
  end

  defp cost(card, true, %{} = deck) when map_size(deck) > 0, do: Deck.card_mana_cost(deck, card)
  defp cost(card, _, _), do: Card.cost(card)

  defp legendary?(card) do
    with id when is_integer(id) <- Card.dbf_id(card),
         [_ | _] <- CardBag.fabled_group(id) do
      true
    else
      _ -> Card.legendary?(card)
    end
  end

  defp type_name("SPELL"), do: "Spell"
  defp type_name("WEAPON"), do: "Weapon"
  defp type_name("LOCATION"), do: "Location"
  defp type_name("HERO"), do: "Hero"
  defp type_name("MINION"), do: "Minion"
  defp type_name(other), do: Recase.to_title(to_string(other))

  defp image_urls(card) do
    dbf_id = Card.dbf_id(card)
    art = Card.art_url(card) || HearthstoneJson.art_url(dbf_id)
    {tile_url, card_url} = CardBag.tile_card_url(dbf_id)
    {hsj_tile_url, hsj_card_url} = HearthstoneJson.tile_card_url(dbf_id)

    chosen_card_url = hsj_card_url || card_url || Card.card_url(card)
    chosen_art_url = art || tile_url || hsj_tile_url || chosen_card_url

    {chosen_art_url, chosen_card_url}
  end

  defp border_style(card) do
    classes =
      case Card.classes(card) do
        [_ | _] = list ->
          list
          |> Enum.map(&String.upcase/1)
          |> Enum.reject(&(&1 in [nil, "", "NEUTRAL"]))
          |> case do
            [] -> ["NEUTRAL"]
            valid -> valid
          end

        _ ->
          ["NEUTRAL"]
      end

    case classes do
      [c1, c2 | _] ->
        color1 = class_var(c1)
        color2 = class_var(c2)

        "border: 1.5px solid transparent; background-image: linear-gradient(to right, #0f172a, #0f172a), linear-gradient(135deg, color-mix(in srgb, #{color1} 60%, transparent) 50%, color-mix(in srgb, #{color2} 60%, transparent) 50%); background-origin: border-box; background-clip: padding-box, border-box;"

      [c1] when c1 != "NEUTRAL" ->
        "border: 1.5px solid color-mix(in srgb, #{class_var(c1)} 60%, transparent);"

      _ ->
        "border: 1.5px solid rgba(148, 163, 184, 0.2);"
    end
  end

  defp class_var(class) when is_binary(class), do: "var(--color-#{String.downcase(class)})"
  defp class_var(_), do: "var(--color-neutral)"

  @size_specs %{
    "sm" => %{
      container_class: "tw-w-12 tw-h-12",
      slot_card_top: "width: 55px; height: 49px;",
      slot_cropped: "width: 51px; height: 51px;",
      card_top_size: "width: 52px; height: 49px;",
      card_top_img: "width: 52px; height: 79px; max-width: none; display: block;",
      card_top_mask_offset: "3.5px",
      card_top_stack_offset: 3,
      cropped_stack_offset: 3,
      legend: %{top: "1px", right: "3px", font_size: "12px"}
    },
    "lg" => %{
      container_class: "tw-w-16 tw-h-16",
      slot_card_top: "width: 80px; height: 71px;",
      slot_cropped: "width: 70px; height: 70px;",
      card_top_size: "width: 76px; height: 71px;",
      card_top_img: "width: 76px; height: 115px; max-width: none; display: block;",
      card_top_mask_offset: "5px",
      card_top_stack_offset: 4,
      cropped_stack_offset: 6,
      legend: %{top: "3px", right: "5px", font_size: "16px"}
    },
    "md" => %{
      container_class: "tw-w-14 tw-h-14",
      slot_card_top: "width: 67px; height: 60px;",
      slot_cropped: "width: 61px; height: 61px;",
      card_top_size: "width: 64px; height: 60px;",
      card_top_img: "width: 64px; height: 97px; max-width: none; display: block;",
      card_top_mask_offset: "4px",
      card_top_stack_offset: 3,
      cropped_stack_offset: 5,
      legend: %{top: "2px", right: "4px", font_size: "14px"}
    }
  }

  defp size_spec(size), do: Map.get(@size_specs, size, @size_specs["md"])

  defp container_size_classes(size), do: size_spec(size).container_class

  defp slot_size_style(size, "card_top"), do: size_spec(size).slot_card_top
  defp slot_size_style(size, _mode), do: size_spec(size).slot_cropped

  defp card_top_size_style(size), do: size_spec(size).card_top_size

  defp card_top_img_style(size), do: size_spec(size).card_top_img

  defp card_top_mask_style(size) do
    gradient =
      "linear-gradient(to bottom, black calc(100% - #{size_spec(size).card_top_mask_offset}), transparent 100%)"

    "-webkit-mask-image: #{gradient}; mask-image: #{gradient};"
  end

  defp stack_card_top_offset(size), do: size_spec(size).card_top_stack_offset

  defp stack_card_top_style(layer, size) do
    offset = stack_card_top_offset(size)
    top = (1 - layer) * round(offset * 0.6)
    left = layer * offset
    z_index = 10 - layer * 2
    filter = if layer == 1, do: "filter: brightness(0.72);", else: "filter: brightness(0.60);"
    "top: #{top}px; left: #{left}px; z-index: #{z_index}; #{filter}"
  end

  defp legend_star_style(size) do
    %{top: top, right: right, font_size: font_size} = size_spec(size).legend

    "top: #{top}; right: #{right}; font-size: #{font_size}; text-shadow: 0 1px 3px rgba(0,0,0,0.9); -webkit-text-stroke: 0.5px #78350f; line-height: 1;"
  end

  defp number_pos_style("top-left", "sm", val)
       when long_value?(val),
       do: "top: 1px; left: 2px;"

  defp number_pos_style("top-left", "sm", _), do: "top: 1px; left: 3px;"

  defp number_pos_style("top-left", "lg", val)
       when long_value?(val),
       do: "top: 3px; left: 3px;"

  defp number_pos_style("top-left", "lg", _), do: "top: 3px; left: 5px;"

  defp number_pos_style("top-left", _, val)
       when long_value?(val),
       do: "top: 2px; left: 2px;"

  defp number_pos_style("top-left", _, _), do: "top: 2px; left: 4px;"

  defp number_pos_style("bottom-left", "sm", val)
       when long_value?(val),
       do: "bottom: 1px; left: 2px;"

  defp number_pos_style("bottom-left", "sm", _), do: "bottom: 1px; left: 3px;"

  defp number_pos_style("bottom-left", "lg", val)
       when long_value?(val),
       do: "bottom: 3px; left: 3px;"

  defp number_pos_style("bottom-left", "lg", _), do: "bottom: 3px; left: 5px;"

  defp number_pos_style("bottom-left", _, val)
       when long_value?(val),
       do: "bottom: 2px; left: 2px;"

  defp number_pos_style("bottom-left", _, _), do: "bottom: 2px; left: 4px;"

  defp number_pos_style("bottom-right", "sm", val)
       when long_value?(val),
       do: "bottom: 1px; right: 2px;"

  defp number_pos_style("bottom-right", "sm", _), do: "bottom: 1px; right: 3px;"

  defp number_pos_style("bottom-right", "lg", val)
       when long_value?(val),
       do: "bottom: 3px; right: 3px;"

  defp number_pos_style("bottom-right", "lg", _), do: "bottom: 3px; right: 5px;"

  defp number_pos_style("bottom-right", _, val)
       when long_value?(val),
       do: "bottom: 2px; right: 2px;"

  defp number_pos_style("bottom-right", _, _), do: "bottom: 2px; right: 4px;"

  defp number_size_classes("sm", val)
       when long_value?(val),
       do: "tw-text-[10px] -tw-tracking-wider"

  defp number_size_classes("sm", _), do: "tw-text-[11px]"

  defp number_size_classes("lg", val)
       when long_value?(val),
       do: "tw-text-[13px] -tw-tracking-wider"

  defp number_size_classes("lg", _), do: "tw-text-[15px]"

  defp number_size_classes(_, val)
       when long_value?(val),
       do: "tw-text-[11px] -tw-tracking-wider"

  defp number_size_classes(_, _), do: "tw-text-[13px]"

  defp shape_classes("circle"), do: "tw-rounded-full"
  defp shape_classes("oval"), do: "tw-rounded-[14px]"
  defp shape_classes(_), do: "tw-rounded-lg"

  defp inner_shape_classes("circle"), do: "tw-rounded-full"
  defp inner_shape_classes("oval"), do: "tw-rounded-[12px]"
  defp inner_shape_classes(_), do: "tw-rounded-[6px]"

  defp extra_layers(count) when is_integer(count) and count >= 3, do: [2, 1]
  defp extra_layers(count) when is_integer(count) and count == 2, do: [1]
  defp extra_layers(_), do: []

  defp layer_offset(size), do: size_spec(size).cropped_stack_offset

  defp stack_card_style(border_style, layer, size) do
    offset = layer_offset(size)
    top = (1 - layer) * offset
    left = layer * offset
    z_index = 10 - layer * 2
    "top: #{top}px; left: #{left}px; z-index: #{z_index}; #{border_style}"
  end

  defp stack_brightness_class(1), do: "tw-brightness-[0.82]"
  defp stack_brightness_class(2), do: "tw-brightness-[0.70]"
  defp stack_brightness_class(_), do: "tw-brightness-[0.80]"

  defp card_title(card, count, type_name) when is_integer(count) and count > 1 do
    "#{count}x #{card.name} (#{type_name})"
  end

  defp card_title(card, _count, type_name) do
    "#{card.name} (#{type_name})"
  end
end
