defmodule Oauthex.Plugs.InfoFetcher do
  import Plug.Conn

  def init(key) do
    platform_key =
      cond do
        is_atom(key) -> key
        true -> :platform
      end

    [key: platform_key]
  end

  def call(conn, opts) do
    params = conn.params
    platform_key = opts[:key]
    platform = params[to_string(platform_key)] |> String.to_atom

    info = Oauthex.info(platform, params)
    conn |> assign(:oauthex_info, info)
  end
end
