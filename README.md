# Oauthex

Oauth2 Client in Phoenix, aim to make Oauth2 authorization simple.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `oauthex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:oauthex, "~> 0.1.0"}]
    end
    ```

  2. Ensure `oauthex` is started before your application:

    ```elixir
    def application do
      [applications: [:oauthex]]
    end
    ```

## Target

1. Convention over configuration
2. Easy to use with Phoenix
3. Easy to test

## Code Example

```elixir
defmodule Demo.Router do
  ...
  # use many platform as login method
  # we make a resource route
  # if we visit /auth/github, which means we want use github's oauth2 service
  resources "/auth/:platform", AuthController, only: [:new, :show], singleton: true
  ...
end

defmodule Demo.AuthController do
  use Demo.Web, :controller

  # you want use oauth2 service with github and twitter
  use Oauthex, [:github, :twitter]

  # when you need github oauth service
  # the redirect_uri is /auth/github/new
  plug Oauthex.Plugs.CodeFetcher when action in [:show]
  plug Oauthex.Plugs.InfoFetcher when action in [:new]

  def new(conn, _params) do
    info = conn.assigns[:oauthex_info]

    # now you get the info
  end

  def show(conn, _params) do
    url = conn.assigns[:oauthex_code_url]
    case url do
      :error -> redirect(conn, to: "/")
      _ -> redirect(conn, external: url)
    end
  end
end
```
