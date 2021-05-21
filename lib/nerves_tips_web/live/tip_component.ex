defmodule NervesTipsWeb.TipComponent do
  use NervesTipsWeb, :live_component

  def mount(socket) do
    # We'll only have the user when admin is authenticated
    # but we check for it during render, so easier to
    # just put and empty user in the assigns
    {:ok, assign_new(socket, :user, fn -> nil end)}
  end

  def render(assigns) do
    ~L"""
    <!-- adapted from https://tailwindcomponents.com/component/twitter-card-1-->
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
          <button phx-click="delete" phx-value-id="<%= @tip.id %>" type="button" class="bg-red-500 dark:bg-red-700 rounded-md p-2 inline-flex items-center justify-center text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500" data-confirm="Are you sure you want to delete tip #<%= @tip.number %>">
            <span class="sr-only">Delete</span>
            <!-- Heroicon name: outline/x -->
            <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
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
end
