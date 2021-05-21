defmodule NervesTipsWeb.AdminLive do
  use NervesTipsWeb, :live_view

  alias NervesTips.{Repo, Schema.Tip}

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    offset = get_connect_params(socket)["timezone_offset"] || 0

    socket =
      socket
      |> assign(
        changeset: new_changeset(user_id),
        preview: false,
        queue: NervesTips.queued_tips(),
        timezone_offset: offset
      )
      |> assign_new(:user, fn -> NervesTips.get_user!(user_id) end)
      |> allow_upload(:image,
        accept: [".png"],
        auto_upload: true,
        max_entries: 1,
        progress: &handle_progress/3
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", params, socket) do
    socket = update_changeset(socket, params["tip"])

    case uploaded_entries(socket, :image) do
      {_, [%{valid?: false, client_name: name}]} ->
        {:noreply,
         put_flash(socket, :error, "File must be .png extension. Got #{Path.extname(name)}")}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("save", _params, socket) do
    %{socket.assigns.changeset | action: nil}
    |> Repo.insert()
    |> case do
      {:ok, tip} ->
        sorted = sort_by_number([tip | socket.assigns.queue])

        {:noreply,
         assign(socket, queue: sorted, changeset: new_changeset(socket.assigns.user.id))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("preview", _params, socket) do
    {:noreply, assign(socket, preview: true)}
  end

  def handle_event("preview-close", _params, socket) do
    # This is the preview of an unsaved tip
    {:noreply, assign(socket, preview: false)}
  end

  def handle_event("delete", %{"id" => ""}, socket) do
    # This is the preview of an unsaved tip
    {:noreply, assign(socket, preview: false)}
  end

  def handle_event("delete", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)

    _ =
      Enum.find(socket.assigns.queue, &(&1.id == id))
      |> Repo.delete()

    # Deleting a tip may change the next number
    socket =
      update_changeset(socket, %{number: nil})
      |> assign(queue: Enum.reject(socket.assigns.queue, &(&1.id == id)))

    {:noreply, socket}
  end

  def handle_event(<<"m", direction::binary-1, id_str::binary>>, _params, socket) do
    id = String.to_integer(id_str)

    queue =
      move_in_queue(direction, id, socket.assigns.queue, [])
      |> sort_by_number()

    {:noreply, assign(socket, queue: queue)}
  end

  defp handle_progress(:image, entry, socket) do
    socket =
      if entry.done? do
        consume_uploaded_entry(
          socket,
          entry,
          &add_image_to_changeset(socket, &1.path, entry.client_type)
        )
      else
        # TODO: Remove this after done testing
        :timer.sleep(Enum.random(100..500))
        socket
      end

    {:noreply, socket}
  end

  defp add_image_to_changeset(socket, path, type) do
    attrs = %{
      image_type: type,
      image: File.read!(path)
    }

    update_changeset(socket, attrs)
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

  defp update_changeset(socket, attrs) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.apply_changes()
      |> Tip.changeset(attrs)
      |> Map.put(:action, :update)

    assign(socket, changeset: changeset)
  end
end
