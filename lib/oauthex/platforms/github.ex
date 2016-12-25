defmodule Oauthex.Platforms.Github do
  use Oauthex.Base

  alias Oauthex.Client
  alias Oauthex.Config

  @header [{"Accept", "application/json"}]

  @code_endpoint "https://github.com/login/oauth/authorize"
  @auth_endpoint "https://github.com/login/oauth/access_token"
  @info_endpoint "https://api.github.com/user"

  def code_url do
    query_string =
      default_config
      |> Keyword.keys
      |> Kernel.--([:client_secret])
      |> sub_config
      |> Enum.sort
      |> Plug.Conn.Query.encode

    @code_endpoint <> "/?" <> query_string
  end

  def auth_client do
    struct Client, %{
      url: @auth_endpoint,
      header: @header,
      params: sub_config([
          :client_id, :client_secret, :code,
          :redirect_uri, :state
        ])
    }
  end

  def info_client do
    struct Client, %{
      url: @info_endpoint,
      header: @header,
      params: sub_config([:access_token])
    }
  end

  def code_callback(code) do
    state = code[:state]
    code = code[:code]

    cond do
      state == config()[:state] && code ->
        Config.add_config(:github, [code: code])
        auth_client
      true ->
        %Client{}
    end
  end

  def auth_callback(auth) do
    token = auth[:access_token]

    cond do
      is_binary(token) ->
        Config.add_config(:github, [access_token: token])
        info_client
      true ->
        %Client{}
    end
  end

  def info_callback(info) do
    cond do
      is_map(info) -> info
      true -> %{}
    end
  end

  def default_config do
    [
      scope: "user",
      state: nil,
      client_id: nil,
      client_secret: nil,
      redirect_uri: nil,
      allow_signup: true
    ]
  end

  defp sub_config(key_list) do
    config()
    |> Keyword.take(key_list)
    |> Enum.reject(fn({_, value}) -> value == nil end)
  end
end
