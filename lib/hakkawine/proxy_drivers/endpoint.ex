defmodule Hakkawine.ProxyDrivers.Endpoint do
  alias Hakkawine.ProxyDrivers.Config

  defstruct [:role, :name, :host, :port, :config]

  @type t :: %__MODULE__{
          role: :client | :server,
          name: String.t(),
          host: String.t(),
          port: integer(),
          config: Config.t()
        }
end
