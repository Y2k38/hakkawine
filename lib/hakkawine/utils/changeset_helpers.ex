defmodule Hakkawine.Utils.ChangesetHelpers do
  import Ecto.Changeset

  def validate_json_field(changeset, field, opts \\ []) when is_atom(field) do
    max_bytes = Keyword.get(opts, :max_bytes, 4096)
    trim? = Keyword.get(opts, :trim, true)

    changeset
    |> update_change(field, &normalize_json_value(&1, trim?))
    |> validate_change(field, fn ^field, value ->
      case Jason.encode(value) do
        {:ok, json_str} ->
          if byte_size(json_str) <= max_bytes do
            []
          else
            [{field, "exceeds maximum allowed size of #{max_bytes} bytes"}]
          end

        {:error, _} ->
          [{field, "is not a valid JSON structure"}]
      end
    end)
  end

  defp normalize_json_value(val, true) when is_binary(val), do: String.trim(val)
  defp normalize_json_value(val, _trim), do: val
end
