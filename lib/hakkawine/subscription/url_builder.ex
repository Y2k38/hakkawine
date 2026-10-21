defmodule Hakkawine.Subscription.UrlBuilder do
  use HakkawineWeb, :verified_routes

  def generate_all(sub, name) do
    base_url = HakkawineWeb.Endpoint.url() <> ~p"/sub/#{sub.id}/#{sub.uuid}"

    %{
      base_url: base_url,
      clash_url: to_clash(base_url, name),
      shadowrocket_url: to_shadowrocket(base_url, name)
    }
  end

  defp to_clash(base_url, name) do
    encoded_url = URI.encode_www_form(base_url)
    encoded_name = URI.encode_www_form(name)

    "clash://install-config?url=#{encoded_url}&name=#{encoded_name}"
  end

  defp to_shadowrocket(base_url, remark) do
    b64_url = Base.encode64(base_url, padding: false)
    encoded_remark = URI.encode_www_form(remark)

    "shadowrocket://add/sub://#{b64_url}?remark=#{encoded_remark}"
  end
end
