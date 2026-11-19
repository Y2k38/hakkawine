defmodule HakkawineWeb.UserAccountLive.Components.ChangeEmailModal do
  use HakkawineWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       email: "",
       code: "",
       is_valid?: false,
       countdown: 0
     )}
  end

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
              A verification code will be sent to your new email. The account email will be updated after successful verification.
            </p>

            <form phx-change="validate" phx-submit="change_email" phx-target={@myself}>
              <div class="form-control w-full mb-4">
                <label class="label">
                  <span class="label-text font-medium text-base-content/80">Email Address</span>
                </label>
                <input
                  type="email"
                  name="email"
                  value={@email}
                  class="input input-bordered w-full"
                  required
                />
              </div>
              <div class="form-control w-full mb-6">
                <label class="label">
                  <span class="label-text font-medium text-base-content/80">Verification Code</span>
                </label>
                <div class="join w-full">
                  <input
                    type="text"
                    name="code"
                    value={@code}
                    class="input input-bordered join-item w-full"
                    required
                  />
                  <button
                    type="button"
                    class="btn bg-orange-500 hover:bg-orange-600 text-white border-orange-500 disabled:bg-base-300 disabled:border-none disabled:text-base-content/40 join-item min-w-[110px]"
                    phx-click="get_code"
                    phx-target={@myself}
                    disabled={@countdown > 0 or @email == ""}
                  >
                    <%= if @countdown > 0 do %>
                      {"#{@countdown}s"}
                    <% else %>
                      Get Code
                    <% end %>
                  </button>
                </div>
              </div>

              <div class="modal-action">
                <button type="button" class="btn btn-ghost" phx-click="close_modal">Cancel</button>
                <button
                  type="submit"
                  class="btn bg-orange-500 hover:bg-orange-600 text-white border-none disabled:bg-base-300 disabled:text-base-content/40"
                  disabled={!@is_valid?}
                >
                  Confirm Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button phx-click="close_modal">close</button>
      </form>
    </dialog>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    email = Map.get(params, "email", "")
    code = Map.get(params, "code", "")
    is_valid = email != "" and code != ""

    {:noreply, assign(socket, email: email, code: code, is_valid?: is_valid)}
  end

  @impl true
  def handle_event("get_code", _params, socket) do
    Process.send_after(self(), :tick_email_countdown, 1000)
    {:noreply, assign(socket, countdown: 60)}
  end

  @impl true
  def handle_event("change_email", params, socket) do
    send(self(), {:change_email, params})
    {:noreply, socket}
  end
end
