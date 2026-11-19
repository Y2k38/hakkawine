defmodule HakkawineWeb.UserAccountLive.Components.ChangePassModal do
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

        <p class="text-sm text-base-content/70 mb-6">
          Please enter your current password and new password (must be between 12 and 72 characters long). All sessions will require re-login after changing.
        </p>

        <form phx-change="validate" phx-submit="change_pass" phx-target={@myself}>
          <div class="form-control w-full mb-4">
            <label class="label">
              <span class="label-text">Current Password</span>
            </label>
            <input
              type="password"
              name="current_password"
              value={@current_password}
              class="input input-bordered w-full"
              required
            />
          </div>
          <div class="form-control w-full mb-4">
            <label class="label">
              <span class="label-text">New Password</span>
            </label>
            <input
              type="password"
              name="password"
              value={@password}
              class="input input-bordered w-full"
              required
              minlength="12"
            />
          </div>

          <div class="form-control w-full mb-6">
            <label class="label">
              <span class="label-text">Confirm New Password</span>
            </label>
            <input
              type="password"
              name="password_confirmation"
              value={@password_confirmation}
              class="input input-bordered w-full"
              required
              minlength="12"
            />
          </div>

          <div class="modal-action">
            <button type="button" class="btn btn-ghost" phx-click="close_modal">Cancel</button>
            <button type="submit" class="btn btn-primary" disabled={!@is_valid?}>Confirm Changes</button>
          </div>
        </form>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button phx-click="close_modal">close</button>
      </form>
    </dialog>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       current_password: "",
       password: "",
       password_confirmation: "",
       is_valid?: false
     )}
  end

  @impl true
  def handle_event("validate", params, socket) do
    cur = Map.get(params, "current_password", "")
    pwd = Map.get(params, "password", "")
    conf = Map.get(params, "password_confirmation", "")
    is_valid = cur != "" and pwd != "" and conf != ""

    {:noreply,
     assign(socket,
       current_password: cur,
       password: pwd,
       password_confirmation: conf,
       is_valid?: is_valid
     )}
  end

  @impl true
  def handle_event("change_pass", params, socket) do
    send(self(), {:change_pass, params})
    {:noreply, socket}
  end
end
