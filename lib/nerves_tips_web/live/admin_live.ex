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
        sorted = Enum.sort_by([tip | socket.assigns.queue], & &1.number)

        {:noreply,
         assign(socket, queue: sorted, changeset: new_changeset(socket.assigns.user.id))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("preview", _params, socket) do
    {:noreply, assign(socket, preview: true)}
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

  defp new_changeset(user_id) do
    Tip.changeset(%Tip{}, %{created_by_id: user_id})
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
