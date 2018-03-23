defmodule TanksWeb.PageView do
  use TanksWeb, :view
  alias Tanks.Entertainment
  alias TanksWeb.PageView

  @doc """
  json response template to ajax querying game status
  """
  def render("show.json", %{game_status: status}) do
    %{data: %{game_status: status}}
  end

  def game_cards_html do
    cards_html = Entertainment.list_games
                 |> Enum.reduce("", fn (game,acc) -> acc <> game_card_html(game) end)
    raw "<div class='game-cards'>#{cards_html}</div>"
  end

  # TODO: fill in anchor links for joining and observing games.
  def game_card_html(%{status: status} = game) do
    join_button = status == :open && "<a href='' class='btn btn-join'>Join</a>" || ''
    observe_button = (status == :full || status == :in_battle ) && "<a href='' class='btn btn-observe'>Observe</a>" || ''
    html = """
            <div class="game-card status-#{status} data-gamename='#{game.name}'">
              <div class="status">#{status |> String.capitalize}</div>
              <h3 class="game-name">#{game.name}</h3>
              #{join_button}
              #{observe_button}
            </div>
           """
  end

end
