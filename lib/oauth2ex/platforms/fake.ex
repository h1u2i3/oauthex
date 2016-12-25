defmodule Oauthex.Platforms.Fake do
  @moduledoc false
  use Oauthex.Base

  alias Oauthex.Client

  @res %Client{}

  def code_url, do: :error
  def auth_client, do: @res
  def info_client, do: @res

  def code_callback(_code), do: auth_client
  def auth_callback(_auth), do: info_client
  def info_callback(_info), do: %{}

  def default_config, do: []
end
