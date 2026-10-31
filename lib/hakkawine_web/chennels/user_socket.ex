defmodule HakkawineWeb.Channels.UserSocket do
  use Phoenix.LiveView.Socket

  # alias Hakkawine.Sessions

  @impl true
  def connect(_params, socket, connect_info) do
    session = connect_info[:session] || %{}
    user_id = session["user_id"]
    session_id = session["session_id"]

    {:ok, assign(socket, user_id: user_id, session_id: session_id)}
  end

  @impl true
  def id(socket) do
    user_id = socket.assigns[:user_id]
    session_id = socket.assigns[:session_id]

    if user_id && session_id do
      # if user_id && session_id && Sessions.valid_session?(user_id, session_id) do
      "user_session:#{user_id}:#{session_id}"
    else
      nil
    end
  end
end
