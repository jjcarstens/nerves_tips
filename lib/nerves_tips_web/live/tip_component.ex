defmodule NervesTipsWeb.TipComponent do
  use NervesTipsWeb, :live_component

  alias NervesTips.{Repo, Schema.Tip}
  alias Phoenix.PubSub

  def mount(socket) do
    # We'll only have the user when admin is authenticated
    # but we check for it during render, so easier to
    # just put an empty user in the assigns

    socket =
      socket
      |> assign_new(:user, fn -> nil end)
      |> allow_upload(:image,
        accept: [".png"],
        auto_upload: true,
        max_entries: 1,
        progress: &handle_progress/3
      )

    {:ok, socket}
  end

  def render(%{changeset: c} = assigns) when not is_nil(c) do
    ~L"""
    <div class="bg-white dark:bg-gray-800 dark:text-gray-300 border-dashed border-black dark:border-gray-400 p-4 rounded-xl border max-w-xl">
      <%= f = form_for @changeset, "#", [phx_change: :validate, phx_submit: :save, phx_target: @myself] %>
        <%= text_input f, :number, class: "bg-transparent block border border-grey-light w-full p-3 rounded mb-4", placeholder: "Number", inputmode: "numeric", pattern: "[0-9]*" %>
        <%= error_tag f, :number %>

        <%= text_input f, :title, class: "bg-transparent block border border-grey-light w-full p-3 rounded mb-4", placeholder: "Title" %>
        <%= error_tag f, :title %>

        <%= textarea f, :description, class: "bg-transparent block border border-grey-light w-full p-3 rounded mb-4", placeholder: "Description" %>
        <%= error_tag f, :description %>


        <section phx-drop-target="<%= @uploads.image.ref %>">
          <%= live_file_input @uploads.image %>

          <%= for entry <- @uploads.image.entries do %>
            <article class="upload-entry">
              <progress value="<%= entry.progress %>" max="100"> <%= entry.progress %>% </progress>

              <button phx-click="cancel-upload" phx-value-ref="<%= entry.ref %>" aria-label="cancel">&times;</button>

              <%= for err <- upload_errors(@uploads.image, entry) do %>
                <p class="alert alert-danger"><%= to_string(err) %></p>
              <% end %>

            </article>
          <% end %>

          <%= if image = Ecto.Changeset.get_field(@changeset, :image) do %>
            <img class="mt-2 rounded-2xl border border-gray-100 dark:border-gray-700" src="data:<%= Ecto.Changeset.get_field(@changeset, :image_type) %>;base64,<%= Base.encode64(image) %>"/>
          <% end %>

        </section>
      </form>
      <div class="flex mt-4">
        <button phx-click="save" phx-target="<%= @myself %>" class="text-base rounded-r-none cursor-pointer flex justify-center px-4 py-2 rounded font-bold hover:bg-green-500 hover:text-green-100 bg-green-300 text-green-700 duration-200 ease-in-out transition disabled:opacity-50 disabled:cursor-not-allowed" <%= unless @changeset.valid?, do: "disabled" %>>
            <div class="flex leading-5">
              <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-save w-5 h-5 mr-1">
                  <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
                  <polyline points="17 21 17 13 7 13 7 21"></polyline>
                  <polyline points="7 3 7 8 15 8"></polyline>
              </svg>
              Save
            </div>
        </button>
        <button phx-click="cancel" phx-target="<%= @myself %>" class="text-base rounded-l-none cursor-pointer flex justify-center px-4 py-2 rounded font-bold hover:bg-yellow-500 hover:text-yellow-100 bg-yellow-300 text-yellow-700 duration-200 ease-in-out transition">
            <div class="flex leading-5">
              <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-save w-5 h-5 mr-1">
                  <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
                  <polyline points="17 21 17 13 7 13 7 21"></polyline>
                  <polyline points="7 3 7 8 15 8"></polyline>
              </svg>
              Cancel
            </div>
        </button>
      </div>
    </div>
    """
  end

  def render(assigns) do
    # <!-- adapted from https://tailwindcomponents.com/component/twitter-card-1-->
    ~L"""
    <div class="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-800 p-4 rounded-xl border max-w-xl" phx-change="edit">
      <%= if @user do%>
        <div class="flex justify-between">
          <div class="flex items-center">
            <img class="h-11 w-11 rounded-full" src="<%= @tip.created_by.avatar_url %>"/>
            <div class="ml-1.5 text-sm leading-tight">
              <span class="text-black dark:text-white font-bold block ">Created By ¬</span>
              <span class="text-gray-500 dark:text-gray-400 font-normal block">@<%= @tip.created_by.nickname %></span>
            </div>
          </div>
          <div class="flex">
            <button phx-click="mu<%= @tip.id %>" type="button" class="bg-gray-100 dark:bg-gray-700 rounded-md rounded-r-none p-2 inline-flex items-center justify-center text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500">
              <span class="sr-only">up</span>
              <!-- Heroicon name: chevron-up -->
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M14.707 12.707a1 1 0 01-1.414 0L10 9.414l-3.293 3.293a1 1 0 01-1.414-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 010 1.414z" clip-rule="evenodd" />
              </svg>
            </button>
            <button phx-click="md<%= @tip.id %>" type="button" class="bg-gray-100 dark:bg-gray-700 rounded-l-none rounded-md p-2 inline-flex items-center justify-center text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500">
              <span class="sr-only">down</span>
              <!-- Heroicon name: chevron-down -->
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
          <button phx-click="edit" phx-value-id="<%= @tip.id %>" phx-target="<%= @myself %>" type="button" class="bg-yellow-400 dark:bg-yellow-600 rounded-md p-2 inline-flex items-center justify-center text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500">
            <span class="sr-only">Edit</span>
            <!-- Heroicon name: pencil/x -->
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
            </svg>
          </button>
          <div class="flex">
          <button phx-click="delete" phx-value-id="<%= @tip.id %>" type="button" class="bg-red-500 dark:bg-red-700 rounded-md p-2 inline-flex items-center justify-center text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500" data-confirm="Are you sure you want to delete tip #<%= @tip.number %>">
            <span class="sr-only">Delete</span>
            <!-- Heroicon name: outline/x -->
            <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
          </div>
        </div>
      <% end %>
      <%= tip_body(@tip) %>
      <%= if @tip.image do %>
      <img class="mt-2 rounded-2xl border border-gray-100 dark:border-gray-700" src="data:<%= @tip.image_type %>;base64,<%= Base.encode64(@tip.image) %>"/>
      <% end %>
      <p class="text-gray-500 dark:text-gray-400 text-base py-1 my-0.5"><%= display_time(@tip, @timezone_offset) %></p>
    </div>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    socket = update_changeset(socket, params["tip"] || %{})

    case uploaded_entries(socket, :image) do
      {_, [%{valid?: false, client_name: name}]} ->
        {:noreply,
         put_flash(socket, :error, "File must be .png extension. Got #{Path.extname(name)}")}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("save", _params, %{assigns: %{id: :new_tip}} = socket) do
    case Repo.insert(%{socket.assigns.changeset | action: nil}) do
      {:ok, _tip} ->
        _ = broadcast_change()

        {:noreply,
         assign(socket,
           changeset: Tip.changeset(socket.assigns.tip, %{created_by_id: socket.assigns.user.id})
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("save", _params, socket) do
    case Repo.update(socket.assigns.changeset) do
      {:ok, tip} ->
        _ = broadcast_change()
        {:noreply, assign(socket, changeset: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    case Repo.delete(socket.assigns.tip) do
      {:ok, tip} ->
        _ = broadcast_change()
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("edit", _params, socket) do
    {:noreply, assign(socket, changeset: Tip.changeset(socket.assigns.tip, %{}))}
  end

  def handle_event("cancel", _params, %{assigns: %{id: :new_tip}} = socket) do
    {:noreply,
     assign(socket,
       changeset: Tip.changeset(socket.assigns.tip, %{created_by_id: socket.assigns.user.id})
     )}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, changeset: nil)}
  end

  defp display_time(tip, offset) do
    (tip.published_on || tip.updated_at || DateTime.utc_now())
    |> DateTime.add(offset * 60 * 60)
    |> Calendar.strftime("%-I:%M %p · %b %-d, %Y")
  end

  defp tip_body(tip) do
    NervesTips.Schema.Tip.build_body(tip)
    |> text_to_html(
      attributes: [class: "text-black dark:text-white block text-xl leading-snug mt-3"]
    )
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

  defp update_changeset(%{assigns: %{id: :new_tip}} = socket, attrs) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.apply_changes()
      |> Tip.changeset(attrs)
      |> Map.put(:action, :update)

    assign(socket, changeset: changeset)
  end

  defp update_changeset(socket, attrs) do
    assign(socket, changeset: Tip.changeset(socket.assigns.tip, attrs))
  end

  defp insert_or_update(%{data: %{id: id}} = changeset) when is_integer(id) do
    Repo.update(changeset)
  end

  defp insert_or_update(changeset) do
    Repo.insert(%{changeset | action: nil})
  end

  defp broadcast_change() do
    PubSub.broadcast(NervesTips.PubSub, "record_changes", :queue_changed)
  end
end
