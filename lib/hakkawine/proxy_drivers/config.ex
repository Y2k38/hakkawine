defmodule Hakkawine.ProxyDrivers.Config do
  use Ecto.Schema

  import Ecto.Changeset

  alias Hakkawine.ProxyDrivers.Vless
  alias Hakkawine.ProxyDrivers.Shadowsocks

  @client_fingerprints [:chrome, :firefox, :safari, :ios, :random]

  def get_random_fingerprint do
    fp =
      case :rand.uniform(100) do
        # 60%
        n when n <= 60 -> :chrome
        # 20%
        n when n <= 80 -> :ios
        # 12%
        n when n <= 92 -> :safari
        # 5%
        n when n <= 97 -> :firefox
        # 3%
        _ -> :random
      end

    fp |> to_string()
    # |> String.capitalize()
  end

  def bool_to_flag(true), do: "1"
  def bool_to_flag(_), do: "0"

  @primary_key false
  embedded_schema do
    field :protocol, Ecto.Enum, values: [:ss, :vless, :anytls, :hy2]

    field :name, :string
    field :host, :string
    field :port, :integer

    field :sub_id, :integer
    field :sub_uuid, :string
    field :password, :string

    field :obfs_host, :string
    field :obfs_port, :integer, default: 443
    field :obfs_uri, :string, default: "/"
    field :obfs_pass, :string

    field :ss_cipher, Ecto.Enum, values: Shadowsocks.ss_ciphers()
    field :ss_plugin, Ecto.Enum, values: Shadowsocks.ss_plugins()
    field :ss_plugin_mode, Ecto.Enum, values: Shadowsocks.ss_plugin_modes()

    field :vless_network, Ecto.Enum, values: Vless.networks()
    field :vless_public_key, :string
    field :vless_private_key, :string
    # Max 8 HEX IDs (0-16 chars) for REALITY authentication
    field :vless_short_ids, {:array, :string}

    field :hy2_obfs, Ecto.Enum, values: [:none, :salamander]

    field :certificate_path, :string
    field :private_key_path, :string
    field :skip_cert_verify, :boolean

    field :bandwidth_up_mbps, :integer
    field :bandwidth_down_mbps, :integer

    field :enable_udp, :boolean, default: true
    # Note: gRPC strictly requires "h2", and Hysteria2 strictly requires "h3".
    field :alpn, :string, default: "h2,http/1.1"
    field :fingerprint, Ecto.Enum, values: @client_fingerprints, default: :chrome
  end

  def changeset(config \\ %__MODULE__{}, params) do
    config
    |> cast(params, __schema__(:fields))
    |> validate_required([
      :protocol,
      :host,
      :port,
      :sub_id,
      :sub_uuid,
      :bandwidth_up_mbps,
      :bandwidth_down_mbps
    ])
    |> validate_protocol_requirements()
    |> validate_shadowsocks_rules()
    |> validate_vless_rules()
    |> validate_anytls_rules()
    |> validate_hysteria2_rules()
  end

  defp validate_protocol_requirements(changeset) do
    case get_field(changeset, :protocol) do
      :ss ->
        validate_required(changeset, [:ss_cipher, :password, :ss_plugin])

      :vless ->
        validate_required(changeset, [
          :vless_network,
          :vless_public_key,
          :vless_private_key,
          :vless_short_ids
        ])

      :hy2 ->
        validate_required(changeset, [:hy2_obfs, :certificate_path, :private_key_path])

      :anytls ->
        validate_required(changeset, [:certificate_path, :private_key_path, :skip_cert_verify])

      _ ->
        changeset
    end
  end

  defp validate_shadowsocks_rules(changeset) do
    case get_field(changeset, :ss_plugin) do
      :simple_obfs ->
        validate_required(changeset, [:ss_plugin_mode, :obfs_host, :obfs_path])

      _ ->
        changeset
    end
  end

  defp validate_vless_rules(changeset) do
    case get_field(changeset, :vless_network) do
      :tcp ->
        validate_required(changeset, [:vless_flow])

      _ ->
        changeset
    end
  end

  defp validate_anytls_rules(changeset) do
    validate_required(changeset, [:skip_cert_verify])
  end

  defp validate_hysteria2_rules(changeset) do
    changeset
  end

  def parse(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:insert)
  end
end
