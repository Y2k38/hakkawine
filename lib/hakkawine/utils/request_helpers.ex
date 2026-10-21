defmodule Hakkawine.Utils.RequestHelpers do
  def get_client_ip(conn) do
    conn.remote_ip |> :inet.ntoa() |> to_string()
  end
end
