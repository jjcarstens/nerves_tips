defmodule NervesTipsWeb.AuthController do
  use NervesTipsWeb, :controller

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: %{errors: errors}}} = conn, _params) do
    errors
    |> Enum.reduce(conn, fn e, aconn ->
      put_flash(aconn, :error, "#{e.message_key} - #{e.message}")
    end)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: %{info: user_info, uid: uid}}} = conn, params) do
    uid = to_string(uid)

    with %{} = user <- NervesTips.user_by_uid_or_nickname(uid, user_info.nickname),
         attrs = %{
           uid: uid,
           nickname: user_info.nickname,
           name: user_info.name,
           avatar_url: user_info.urls.avatar_url
         },
         {:ok, user} <- NervesTips.update_user(user, attrs),
         origin = params["origin"] || "/" do
      conn
      |> configure_session(renew: true)
      |> put_session("user_id", user.id)
      |> assign(:user, user)
      |> put_flash(:info, "#{user.nickname} signed in")
      |> redirect(to: origin)
    else
      _ ->
        conn
        |> put_flash(:error, "Unexpected user. Ignoring..")
        |> redirect(to: "/")
    end
  end

  def login(conn, params) do
    origin = params["origin"] || "/"
    render(conn, "login.html", origin: URI.encode_www_form(origin))
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
