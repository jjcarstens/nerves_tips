# NervesTips

https://tips.nerves-project.org

# Setup

`NervesTips` has a public page for displaying published tips and an admin
page for managing a queue of to-be-released tips. The admin page is
behind Github OAuth application authentication and requires users be
explicitly added in order to accept the authentication:

```elixir
iex> user = NervesTips.Schema.User.changeset(%NervesTips.Schema.User{}, %{nickname: "jjcarstens"})
iex> NervesTips.Repo.insert(user)
{:ok, _user}
```

Then add these for Github OAuth to work:

```elixir
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: "my_client_id",
  client_secret: "my_client_secret"
```

The Github OAuth application callback should be set to `/auth/github/callback`
