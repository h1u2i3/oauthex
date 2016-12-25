defmodule Oauthex.Helper do
  require Logger

  @doc """
  Get platform module from platform name
  """
  def platform_module(platform, callback \\ &(&1)) do
    platform
    |> to_string
    |> Macro.camelize
    |> List.wrap
    |> Kernel.++(["Platforms", "Oauthex"])
    |> Enum.reverse
    |> Module.safe_concat
    |> callback.()
  rescue
    ArgumentError ->
      Oauthex.Platforms.Fake |> callback.()
  end

  @doc """
  Get platform name from platform module
  """
  def platform_name(module, callback \\ &(&1)) do
    module
    |> Module.split
    |> List.last
    |> String.downcase
    |> String.to_atom
    |> callback.()
  end

  @doc """
  Trasform from string keys map to atom keys
  """
  def atom_key_map(string_key_map) when is_map(string_key_map) do
    string_key_map
    |> Enum.map(fn({key, value}) ->
         cond do
           is_binary(key) -> {String.to_atom(key), value}
           true -> {key, value}
         end
       end)
    |> Enum.into(%{})
  end

  @doc """
  Http get request through HTTPoison
  """
  def http_get(url, header, opts) do
    case HTTPoison.get(url, header, opts) do
      {:ok, response} ->
        Poison.decode!(response.body, keys: :atoms)
      {:error, _reason} ->
        :error
    end
  rescue
    _ ->
      :error
  end

  @doc """
  Http post request through HTTPoison
  """
  def http_post(url, body, header, opts) do
    case HTTPoison.post(url, body, header, opts) do
      {:ok, response} ->
        Poison.decode!(response.body, keys: :atoms)
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Debugger method for log
  """
  def debug(result, fun \\ &(&1)) do
    Logger.debug(result |> Macro.to_string |> fun.())
    result
  end
end
