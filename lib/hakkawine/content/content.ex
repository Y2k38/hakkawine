defmodule Hakkawine.Content do
  defp validate_all_images(images) do
    Enum.reduce_while(images, :ok, fn upload_item, _acc ->
      case validate_single_image(upload_item) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp validate_single_image(%Plug.Upload{
         filename: filename,
         path: path,
         content_type: content_type
       }) do
    cond do
      content_type not in @allowed_types ->
        {:error,
         "File '#{filename}' has an unsupported format. Only JPG, PNG, GIF, and WEBP are allowed."}

      file_size_exceeded?(path) ->
        {:error, "File '#{filename}' exceeds the 10MB size limit."}

      true ->
        :ok
    end
  end

  defp validate_single_image(_), do: {:error, "Invalid file upload parameters."}

  defp file_size_exceeded?(path) do
    case File.stat(path) do
      {:ok, %File.Stat{size: size}} -> size > @max_file_size
      _ -> true
    end
  end
end
