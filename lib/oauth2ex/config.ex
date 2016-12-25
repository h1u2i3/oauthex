defmodule Oauthex.Config do
  alias Oauthex.Helper

  @module __MODULE__

  def start_link do
    Agent.start_link(fn -> %{} end, name: @module)
  end

  def get_config(platform) when is_atom(platform) do
    get &Map.get(&1, platform)
  end

  def put_config(platform, config) do
    if platform in allowed_auth do
      update &Map.put(&1, platform, config)
    end
  end

  def add_config(platform, config) do
    if platform in allowed_auth do
      update &Map.put(&1, platform, Keyword.merge(&1[platform], config))
    end
  end

  defp get(fun) do
    Agent.get(@module, fun, 30_000)
  end

  defp update(funs) when is_list(funs) do
    Agent.update(@module, hd(funs), 30_000)
    unless length(tl(funs)) == 0, do: update tl(funs)
  end

  defp update(fun) do
    Agent.update(@module, fun, 30_000)
  end

  defp allowed_auth do
    get(&Map.get(&1, :allowed)) || get_allowed_auth_cache
  end

  defp get_allowed_auth_cache do
    allowed =
      allowed_oauth
      |> Enum.map(&Oauthex.check_platform(&1, fn(m) -> Helper.platform_name(m) end))
      |> Enum.reject(&(&1 == nil))

    update &Map.put(&1, :allowed, allowed)
    allowed
  end

  defp allowed_oauth do
    apply(Oauthex.Dynamic, :allowed_oauth, [])
  end
end
