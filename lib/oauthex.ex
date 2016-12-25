defmodule Oauthex do
  use Application

  alias Oauthex.Helper
  alias Oauthex.Client

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Oauthex.Config, [])
    ]

    opts = [strategy: :one_for_one, name: Oauthex.Supervisor]
    Supervisor.start_link(children, opts)
  end


  @doc """
  Check if the given platform name is valid
  """
  def check_platform(platform, callback \\ &(&1 != Oauthex.Platforms.Fake)) do
    cond do
      is_binary(platform) || is_atom(platform) ->
        Helper.platform_module(platform, callback)
      true ->
        callback.(Oauthex.Platforms.Fake)
    end
  end

  @doc """
  Get the config data for the platform
  """
  def config(platform) when is_binary(platform) do
    platform |> String.to_atom |> config
  end

  def config(platform) when is_atom(platform) do
    platform
    |> Helper.platform_module
    |> apply(:config, [])
  end

  def config(_), do: []

  @doc """
  Get code request url
  """
  def code_url(platform) do
    apply Helper.platform_module(platform), :code_url, []
  end

  @doc """
  Request for info
  """
  def info(platform, params) do
    module = platform |> Helper.platform_module

    params
    |> Helper.debug(&("Get fetch info params: #{&1}"))
    |> Helper.atom_key_map
    |> Helper.debug(&("Get fetch atom: #{&1}"))
    |> module.code_callback
    |> Helper.debug(&("Http client struct: #{&1}"))
    |> Client.post(&module.auth_callback/1)
    |> Client.get(&module.info_callback/1)
  end

  # add `allowed_oauth` to module
  # return the allowed oauth type
  defmacro __using__(opts) do
    opts =
      cond do
        is_list(opts) && length(opts) != 0 -> opts
        true -> default_allowed_auth
      end

    allowed_oauth =
      quote do
        @doc false
        def allowed_oauth do
          unquote(opts)
        end
      end

    quote do
      @after_compile Oauthex
      unquote(allowed_oauth)
    end
  end

  # when the module finish compile
  # fetch the allowed oauth type and save it.
  def __after_compile__(env, _binary) do
    env.module
    |> apply(:allowed_oauth, [])
    |> write_allowed_module
  end

  # set default_allowed_auth only to [:github]
  defp default_allowed_auth do
    [:github]
  end

  # save the compile time data to module
  def write_allowed_module(allowed) do
    beam_file =
      Path.join(Mix.Project.compile_path, "Elixir.Oauthex.Dynamic.beam")

    binary =
      """
      defmodule Oauthex.Dynamic do
        def allowed_oauth do
          #{Macro.to_string(allowed)}
        end
      end
      """
      |> Code.eval_string
      |> elem(0)
      |> elem(2)

    File.rm_rf(beam_file)
    File.write!(beam_file, binary)
  end
end
