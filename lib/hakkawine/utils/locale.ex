defmodule Hakkawine.Utils.Locale do
  alias Hakkawine.System

  def default_language do
    System.get_setting("default_language")
  end

  def supported_languages do
    System.get_setting("supported_languages") || []
  end

  def get_locale(session_lang, accept_language) do
    supported = supported_languages()
    default = default_language()
    browser_locale = parse_accept_language(accept_language, supported)

    cond do
      session_lang in supported ->
        session_lang

      not is_nil(browser_locale) ->
        browser_locale

      true ->
        default
    end
  end

  defp parse_accept_language(nil, _supported), do: nil
  defp parse_accept_language("", _supported), do: nil

  defp parse_accept_language(header, supported) do
    header
    |> String.split(",")
    |> Enum.map(fn item ->
      item
      |> String.split(";")
      |> List.first()
      |> String.trim()
    end)
    |> Enum.find(fn lang ->
      Enum.any?(supported, fn s ->
        String.downcase(lang) == String.downcase(s) ||
          String.starts_with?(String.downcase(lang), String.downcase(s) <> "-")
      end)
    end)
    |> normalize_locale(supported)
  end

  defp normalize_locale(nil, _supported), do: nil

  defp normalize_locale(lang, supported) do
    Enum.find(supported, fn s ->
      String.downcase(s) == String.downcase(lang) ||
        String.starts_with?(String.downcase(lang), String.downcase(s) <> "-")
    end)
  end
end
