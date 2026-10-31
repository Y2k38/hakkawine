defmodule Hakkawine.Utils.UserAgent do
  def parse(user_agent) do
    result = UAParser.parse(user_agent)

    %{
      browser: result.family,
      browser_version: format_version(result.version),
      os: result.os.family,
      os_version: format_version(result.os.version),
      device: result.device.family
    }
  end

  defp format_version(%UAParser.Version{} = v) do
    [v.major, v.minor, v.patch, v.patch_minor]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(".")
    |> case do
      "" -> nil
      str -> str
    end
  end

  defp format_version(v) when is_binary(v), do: v
  defp format_version(_), do: nil
end
