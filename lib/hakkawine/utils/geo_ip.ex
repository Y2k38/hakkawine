defmodule Hakkawine.Utils.GeoIP do
  def lookup(ip_str) do
    %{
      country: parse_country(:locus.lookup(:country, ip_str)),
      asn: parse_asn(:locus.lookup(:asn, ip_str))
    }
  end

  defp parse_country({:ok, data}) do
    %{
      code: get_in(data, ["country", "iso_code"]),
      name: get_in(data, ["country", "names", "en"])
    }
  end

  defp parse_country(_), do: nil

  defp parse_asn({:ok, data}) do
    get_in(data, ["autonomous_system_organization"])
  end

  defp parse_asn(_), do: nil
end
