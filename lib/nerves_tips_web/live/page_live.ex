defmodule NervesTipsWeb.PageLive do
  use NervesTipsWeb, :live_view

  alias NervesTips.{Repo, Schema.Tip}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    offset = get_connect_params(socket)["timezone_offset"] || 0
    {:ok, assign(socket, timezone_offset: offset)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    {:noreply, assign_tips(params, socket)}
  end

  def handle_event("back", _params, socket) do
    {:noreply, push_patch(socket, to: "/")}
  end

  defp assign_tips(%{"tip" => tip_str}, socket) do
    with {num, ""} <- Integer.parse(tip_str),
         tip = Repo.get_by(Tip, number: num),
         true <- not is_nil(tip.published_on) do
      assign(socket, tips: [tip])
    else
      _ ->
        put_flash(socket, :error, "Tip #{tip_str} does not exist")
        |> push_patch(to: "/")
    end
  end

  defp assign_tips(_params, socket) do
    assign(socket, tips: NervesTips.published())
  end
end
