defmodule NervesTipsWeb.PageLive do
  use NervesTipsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    offset = get_connect_params(socket)["timezone_offset"] || 0
    {:ok, assign(socket, tips: NervesTips.published(), timezone_offset: offset)}
  end
end
