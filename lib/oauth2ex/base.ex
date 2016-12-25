defmodule Oauthex.Base do

  @type client :: Oauthex.Client.t
  @type config :: Keyword.t
  @type res :: Map.t
  @type url :: String.t

  @callback default_config() :: Keyword.t

  @callback code_url() :: url
  @callback auth_client() :: client
  @callback info_client() :: client

  @callback code_callback(code :: res) :: any
  @callback auth_callback(auth :: res) :: any
  @callback info_callback(info :: res) :: any

  defmacro __using__(_opts) do
    config_method =
      quote do
        @doc """
        Get the platform config data
        """
        def config do
          platform = Oauthex.Helper.platform_name(__MODULE__)

          if config_data = Oauthex.Config.get_config(platform) do
            config_data
          else
            user_define_config = Application.get_env(:oauthex, platform) || []
            config_data = Keyword.merge(default_config, user_define_config)
            Oauthex.Config.put_config(platform, config_data)

            config_data
            |> Oauthex.Helper.debug(&("Get config data: #{&1}"))
          end
        end
      end

    quote do
      @behaviour unquote(__MODULE__)

      unquote(config_method)
    end
  end
end
