defmodule HakkawineWeb.Helpers.StatusHelper do
  def status_color(:active), do: "text-success"
  def status_color(:expired), do: "text-base-content/60"
  def status_color(:exhausted), do: "text-warning"
  def status_color(:suspended), do: "text-error"
  def status_color(:cancelled), do: "text-base-content/40"
  def status_color(_), do: "text-neutral"

  def format_status(status) when is_atom(status) do
    status
    |> Atom.to_string()
    |> String.capitalize()
  end

  def format_status(status), do: to_string(status)
end
