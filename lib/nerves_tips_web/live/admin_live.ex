defmodule NervesTipsWeb.AdminLive do
  use NervesTipsWeb, :live_view

  alias NervesTips.{Repo, Schema.Tip}

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    offset = get_connect_params(socket)["timezone_offset"] || 0

    socket =
      socket
      |> assign(
        queue: NervesTips.queued_tips(),
        timezone_offset: offset
      )
      |> assign_new(:user, fn -> NervesTips.get_user!(user_id) end)

    if connected?(socket), do: socket.endpoint.subscribe("record_changes")

    {:ok, socket}
  end

  @impl true
  def handle_event(<<"m", direction::binary-1, id_str::binary>>, _params, socket) do
    id = String.to_integer(id_str)

    queue =
      move_in_queue(direction, id, socket.assigns.queue, [])
      |> sort_by_number()

    # Let other views refresh
    _ =
      Phoenix.PubSub.broadcast_from!(NervesTips.PubSub, self(), "record_changes", :queue_changed)

    {:noreply, assign(socket, queue: queue)}
  end

  @impl true
  def handle_info(:queue_changed, socket) do
    {:noreply, assign(socket, queue: NervesTips.queued_tips())}
  end

  defp move_in_queue(_dir, _target, [], acc), do: acc

  defp move_in_queue("d", target, [%{id: target} = a, b | rest], acc)
       when b.number - a.number == 1 do
    NervesTips.swap_tip_numbers!(a, b) ++ rest ++ acc
  end

  defp move_in_queue("u", target, [a, %{id: target} = b | rest], acc)
       when b.number - a.number == 1 do
    NervesTips.swap_tip_numbers!(a, b) ++ rest ++ acc
  end

  defp move_in_queue(direction, target, [%{id: target} = t | rest], acc) do
    # If we get here, the next tip number doesn't exist, so just update the record
    adjuster = if direction == "d", do: 1, else: -1
    {:ok, updated} = NervesTips.update(t, %{number: t.number + adjuster})
    [updated | rest ++ acc]
  end

  defp move_in_queue(direction, target, [next | rest], acc) do
    move_in_queue(direction, target, rest, [next | acc])
  end

  defp new_changeset(user_id) do
    Tip.changeset(%Tip{}, %{created_by_id: user_id})
  end

  defp sort_by_number(queue) do
    Enum.sort_by(queue, & &1.number)
  end
end
