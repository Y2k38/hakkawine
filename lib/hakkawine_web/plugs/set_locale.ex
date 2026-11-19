defmodule HakkawineWeb.Plugs.SetLocale do
  import Plug.Conn

  alias Hakkawine.Utils.Locale

  def init(opts), do: opts

  def call(conn, _opts) do
    session_lang =
      case get_session(conn, :language) do
        lang when is_binary(lang) ->
          case String.trim(lang) do
            "" -> nil
            trimmed -> trimmed
          end

        _ ->
          nil
      end

    accept_language =
      if is_nil(session_lang) or session_lang == "" do
        conn |> get_req_header("accept-language") |> List.first()
      else
        nil
      end

    locale = Locale.get_locale(session_lang, accept_language)

    Gettext.put_locale(HakkawineWeb.Gettext, locale)

    conn
    |> assign(:locale, locale)
  end
end
