defmodule HakkawineWeb.UserAccountLive.Components.BalanceLogsModal do
  use HakkawineWeb, :live_component

  @impl true
  def mount(socket) do
    records = [
      %{
        id: 1,
        time: "2026/10/15 16:26:15",
        type: "Debit",
        change: "-¥22.61",
        balance: "¥0.00",
        remark: "Combined Payment · Upgrade Package (Bronze->Gold)"
      },
      %{
        id: 2,
        time: "2026/9/4 14:40:10",
        type: "Debit",
        change: "-¥32.39",
        balance: "¥22.61",
        remark: "Upgrade Package (Bronze->Gold)"
      },
      %{
        id: 3,
        time: "2026/8/13 01:12:13",
        type: "Credit",
        change: "+¥55.00",
        balance: "¥55.00",
        remark: "WHMCS tblclients.credit import (client_id=153577)"
      }
    ]

    {:ok, assign(socket, records: records, page: 1, total_count: 3)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <dialog class={["modal", @show_modal && "modal-open"]}>
      <div class="modal-box relative w-11/12 max-w-4xl">
        <form method="dialog">
          <button
            class="btn btn-sm btn-circle btn-ghost absolute right-4 top-4"
            phx-click="close_modal"
          >
            ✕
          </button>
        </form>

        <h3 class="font-bold text-lg">{@modal_title}</h3>

        <p class="text-xs text-base-content/60 mt-1">Total {@total_count} items · Page {@page}</p>

        <div class="overflow-x-auto mb-6">
          <table class="table table-zebra w-full text-sm">
            <thead>
              <tr class="text-base-content/70 border-b">
                <th class="font-medium">Time</th>
                <th class="font-medium">Type</th>
                <th class="font-medium">Change</th>
                <th class="font-medium">Balance</th>
                <th class="font-medium">Remark</th>
              </tr>
            </thead>
            <tbody>
              <%= for record <- @records do %>
                <tr class={if record.id == 2, do: "active", else: ""}>
                  <td class="whitespace-nowrap">{record.time}</td>
                  <td>{record.type}</td>
                  <td class={
                    if String.starts_with?(record.change, "-"),
                      do: "text-error font-medium",
                      else: "text-success font-medium"
                  }>
                    {record.change}
                  </td>
                  <td>{record.balance}</td>
                  <td class="max-w-xs truncate" title={record.remark}>{record.remark}</td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>

        <div class="modal-action grid grid-cols-2 sm:flex sm:justify-end gap-2 mt-6">
          <button
            type="button"
            class="btn btn-sm"
            phx-click="prev_page"
            phx-target={@myself}
          >
            Previous
          </button>

          <button
            type="button"
            class="btn btn-sm"
            phx-click="next_page"
            phx-target={@myself}
          >
            Next
          </button>

          <button
            type="button"
            class="btn btn-primary btn-sm col-span-2 sm:col-span-1"
            phx-click="close_modal"
          >
            Close
          </button>
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button phx-click="close_modal">close</button>
      </form>
    </dialog>
    """
  end

  @impl true
  def handle_event("prev_page", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("next_page", _params, socket) do
    {:noreply, socket}
  end
end
