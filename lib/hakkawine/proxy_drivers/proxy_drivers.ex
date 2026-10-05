defmodule Hakkawine.ProxyDrivers do
  alias Hakkawine.ProxyDrivers.Shadowsocks
  alias Hakkawine.ProxyDrivers.Vless
  alias Hakkawine.ProxyDrivers.AnyTLS
  alias Hakkawine.ProxyDrivers.Hysteria2

  def build_proxies(scope, target, subscription) do
    plan_slots = Map.new(subscription.product.plan_slots, fn slot -> {slot.id, slot} end)

    Enum.map(subscription.node_leases, fn node_lease ->
      plan_slot = Map.get(plan_slots, node_lease.plan_slot_id)
      slot_name = plan_slot && plan_slot.slot_name

      config = %{node_lease.proxy_config | name: slot_name}

      build_single_proxy(scope, target, config)
    end)
  end

  defp build_single_proxy(scope, :clash, config) do
    case config.protocol do
      :ss -> Shadowsocks.to_clash_map(scope, config)
      :vless -> Vless.to_clash_map(scope, config)
      :anytls -> AnyTLS.to_clash_map(scope, config)
      :hy2 -> Hysteria2.to_clash_map(scope, config)
    end
  end

  defp build_single_proxy(_scope, _target, config) do
    case config.protocol do
      :ss -> Shadowsocks.to_uri(config)
      :vless -> Vless.to_uri(config)
      :anytls -> AnyTLS.to_uri(config)
      :hy2 -> Hysteria2.to_uri(config)
    end
  end
end
