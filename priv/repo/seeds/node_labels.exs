alias Hakkawine.DatabaseSeeder
alias Hakkawine.System.NodeLabel

labels = [
  %{category: "country", key: "hk", name: "Hong Kong"},
  %{category: "country", key: "kr", name: "South Korea"},
  %{category: "country", key: "jp", name: "Japan"},
  %{category: "country", key: "tw", name: "Taiwan"},
  %{category: "country", key: "us", name: "United States"},
  %{category: "country", key: "sg", name: "Singapore"},
  %{category: "country", key: "in", name: "India"},
  %{category: "country", key: "uk", name: "United Kingdom"},
  %{category: "country", key: "de", name: "Germany"},
  %{category: "country", key: "fr", name: "France"},
  %{category: "country", key: "tr", name: "Turkey"},
  %{category: "route", key: "cn2_gia", name: "Telecom CN2 GIA"},
  %{category: "route", key: "cn2_gt", name: "Telecom CN2 GT"},
  %{category: "route", key: "as9929", name: "Unicom CU Premium (9929)"},
  %{category: "route", key: "as4837", name: "Unicom 4837"},
  %{category: "route", key: "cmi", name: "Mobile CMI"},
  %{category: "route", key: "bgp_optimized", name: "BGP Optimized"},
  %{category: "route", key: "direct", name: "Direct / Standard BGP"},
  %{category: "route", key: "iplc_iepl", name: "IPLC / IEPL Private Line"},
  %{category: "route", key: "international", name: "International BGP"},
  %{category: "route", key: "relay", name: "Relay / Ingress Node"},
  %{category: "tier", key: "lite", name: "Lite"},
  %{category: "tier", key: "standard", name: "Standard"},
  %{category: "tier", key: "premium", name: "Premium"},
  %{category: "tier", key: "one_time", name: "One Time"},
  %{category: "protocol", key: "vless", name: "VLESS"},
  %{category: "protocol", key: "hy2", name: "Hysteria 2"},
  %{category: "protocol", key: "anytls", name: "anyTLS"},
  %{category: "protocol", key: "shadowsocks", name: "Shadowsocks"},
  %{category: "pool", key: "public", name: "Public Resource Pool"},
  %{category: "pool", key: "backup", name: "Backup Resource Pool"},
  %{category: "role", key: "direct", name: "Direct Node"},
  %{category: "role", key: "ingress", name: "Ingress Relay Node"},
  %{category: "role", key: "egress", name: "Egress Landing Node"}
]

DatabaseSeeder.seed(
  NodeLabel,
  [:category, :key],
  labels,
  update_fields: [:name]
)
