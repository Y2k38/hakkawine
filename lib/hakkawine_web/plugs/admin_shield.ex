defmodule HakkawineWeb.Plugs.AdminShield do
  import Plug.Conn

  @internal_prefix "/__internal_system_admin_panel__"

  def init(opts), do: opts

  def call(conn, _opts) do
    secret_path = normalize_path(System.get_setting("admin_path"))
    current_path = conn.request_path

    if secret_path && matches_path?(current_path, secret_path) do
      new_path = String.replace_prefix(current_path, secret_path, @internal_prefix)

      conn
      |> struct(%{request_path: new_path, path_info: String.split(new_path, "/", trim: true)})
      |> put_private(:admin_path_rewritten, true)
    else
      conn
    end
  end

  defp matches_path?(path, target) do
    path == target or String.starts_with?(path, target <> "/")
  end

  defp normalize_path(nil), do: nil
  defp normalize_path(""), do: nil

  defp normalize_path(path) do
    if String.starts_with?(path, "/"), do: path, else: "/" <> path
  end
end
