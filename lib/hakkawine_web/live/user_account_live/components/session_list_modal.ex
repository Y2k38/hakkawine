defmodule HakkawineWeb.UserAccountLive.Components.SessionListModal do
  use HakkawineWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <dialog class={["modal", @show_modal && "modal-open"]}>
      <div class="modal-box relative w-11/12 max-w-2xl">
        <form method="dialog">
          <button
            class="btn btn-sm btn-circle btn-ghost absolute right-4 top-4"
            phx-click="close_modal"
          >
            ✕
          </button>
        </form>

        <h3 class="font-bold text-lg">{@modal_title}</h3>

        <div class="py-4">
          <div class="space-y-4">
            <p class="text-sm text-base-content/70">
              Here are your active login sessions. Recent activity does not necessarily mean the device is currently online. A single device may have multiple sessions.
            </p>

            <%= for session <- @session_list do %>
              <% is_current = session["session_id"] == @session_id %>

              <div class={[
                "card border p-4 rounded-xl",
                is_current && "bg-base-200/60 border-base-300",
                !is_current && "bg-base-100 border-base-200"
              ]}>
                <div class="flex justify-between items-center mb-1">
                  <span class="font-bold text-base">{get_in(session, [
                    "metadata",
                    "ua",
                    "browser"
                  ]) || "Unknown Browser"}</span>
                  <%= if is_current do %>
                    <span class="badge badge-success badge-sm text-success-content font-medium">Current</span>
                  <% end %>
                </div>

                <p class="text-xs text-base-content/70 mb-3">
                  {get_in(session, ["metadata", "ua", "device"]) || "Unknown Device"} · {get_in(
                    session,
                    ["metadata", "ua", "os"]
                  ) || "Unknown OS"} · {get_in(session, ["user_agent"])}
                </p>

                <div class="flex justify-between items-end">
                  <div>
                    <div class="text-sm font-medium">{get_in(session, ["ip_address"])}</div>
                    <div class="text-xs text-base-content/60">
                      {get_in(session, ["metadata", "ip", "country"]) || "Unknown Country"} · {get_in(
                        session,
                        ["ip", "asn"]
                      ) || "Unknown ASN"}
                    </div>
                  </div>

                  <button
                    class="btn btn-ghost btn-xs text-error hover:bg-error/10"
                    phx-click="logout_session"
                    phx-value-session_id={session["session_id"]}
                  >
                    Log out
                  </button>
                </div>
              </div>
            <% end %>
          </div>

          <div class="modal-action flex justify-between items-center mt-6">
            <button
              class="btn btn-ghost btn-sm text-error hover:bg-error/10"
              phx-click="logout_other_sessions"
            >
              Log out all other devices
            </button>

            <button
              class="btn btn-primary px-6"
              phx-click="close_modal"
            >
              Done
            </button>
          </div>
        </div>
      </div>

      <form method="dialog" class="modal-backdrop">
        <button phx-click="close_modal">close</button>
      </form>
    </dialog>
    """
  end
end
