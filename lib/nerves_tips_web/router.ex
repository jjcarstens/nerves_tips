defmodule NervesTipsWeb.Router do
  use NervesTipsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {NervesTipsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :ensure_authenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NervesTipsWeb do
    pipe_through :browser

    live "/", PageLive, :index
    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
  end

  scope "/auth", NervesTipsWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", NervesTipsWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through [:browser, :admin]
    live_dashboard "/dashboard", metrics: NervesTipsWeb.Telemetry
    live "/admin", NervesTipsWeb.AdminLive, :index
  end

  defp ensure_authenticated(%{assigns: %{user: _user}} = conn, _params), do: conn

  defp ensure_authenticated(conn, _params) do
    if get_session(conn, "user_id") do
      # Maybe put user here?
      conn
    else
      conn
      |> put_flash(:error, "Must be authorized to view this page")
      |> redirect(to: "/login?origin=#{URI.encode_www_form(conn.request_path)}")
      |> halt()
    end
  end
end
