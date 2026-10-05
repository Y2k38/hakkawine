defmodule Hakkawine.Utils do
  def format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map(fn {field, errs} -> "  - #{field}: #{Enum.join(errs, ", ")}" end)
    |> Enum.join("\n")
  end
end
