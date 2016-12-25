defmodule Oauthex.Client do
  alias Oauthex.Helper

  defstruct url: nil, params: [], body: "", header: []

  def get(struct, callback \\ &(&1)) do
    %{url: url, header: header, params: params} = struct

    cond do
      is_fake?(struct) ->
        %{}
      true ->
        url
        |> Helper.debug(&("Oauthex request for url: #{&1}"))
        |> Helper.http_get(header, [params: params])
        |> Helper.debug(&("Oauthex request result: #{&1}"))
    end |> callback.()
  end

  def post(struct, callback \\ &(&1)) do
    %{url: url, header: header, params: params, body: body} = struct

    cond do
      is_fake?(struct) ->
        %{}
      true ->
        url
        |> Helper.debug(&("Oauthex request for url: #{&1}"))
        |> Helper.http_post(body, header, [params: params])
        |> Helper.debug(&("Oauthex request result: #{&1}"))
    end |> callback.()
  end

  # don't use nil but add a Fake platform
  def is_fake?(struct) do
    struct.url == nil
  end
end
