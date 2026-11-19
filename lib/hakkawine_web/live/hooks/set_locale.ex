defmodule HakkawineWeb.Live.Hooks.SetLocale do
  import Phoenix.Component
  import Phoenix.LiveView

  alias Hakkawine.Utils.Locale

  def on_mount(_initial_arg, _params, session, socket) do
    session_lang = session["language"]

    accept_language =
      if (is_nil(session_lang) or session_lang == "") and connected?(socket) do
        case get_connect_info(socket, :x_headers) do
          headers when is_list(headers) ->
            case List.keyfind(headers, "accept-language", 0) do
              {"accept-language", val} -> val
              _ -> nil
            end

          _ ->
            nil
        end
      else
        nil
      end

    locale = Locale.get_locale(session_lang, accept_language)

    Gettext.put_locale(HakkawineWeb.Gettext, locale)

    {:cont, assign(socket, locale: locale)}
  end
end
