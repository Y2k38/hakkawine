defmodule HakkawineWeb.Router do
  use HakkawineWeb, :router

  alias HakkawineWeb.Plugs.BlockQqWechat
  alias HakkawineWeb.Plugs.FetchCurrentUser
  alias HakkawineWeb.Plugs.EnsureAuthenticated
  alias HakkawineWeb.Plugs.RedirectIfAuthenticated

  # Basic (Common Browser Stack)
  pipeline :browser_base do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HakkawineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug BlockQqWechat
    plug FetchCurrentUser
  end

  # Guest
  pipeline :guest_browser do
    plug :browser_base
    plug RedirectIfAuthenticated
  end

  # Logged-in user
  pipeline :user_browser do
    plug :browser_base
    plug :put_layout, html: {HakkawineWeb.Layouts, :app}
    plug EnsureAuthenticated
  end

  # Admin
  pipeline :admin_browser do
    plug :user_browser
    plug :put_layout, html: {HakkawineWeb.Layouts, :admin}
  end

  # Public API
  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", HakkawineWeb do
    pipe_through [:guest_browser]

    get "/register", AuthController, :register_page
    post "/send-code", AuthController, :send_code
    post "/register", AuthController, :register

    get "/log_in", AuthController, :log_in_page
    post "/log_in", AuthController, :log_in

    get "/forgot_password", AuthController, :forgot_password_page
    post "/send_reset_link", AuthController, :send_reset_link

    get "/reset_password", AuthController, :reset_password_page
    post "/reset_password", AuthController, :reset_password
  end

  scope "/auth", HakkawineWeb do
    pipe_through [:user_browser]

    delete "/log_out", AuthController, :log_out
  end

  scope "/", HakkawineWeb do
    pipe_through :user_browser

    get "/", PageController, :index
  end

  scope "/", HakkawineWeb do
    pipe_through [:user_browser]

    get "/home", PageController, :home
    get "/plans", PlanController, :index
    get "/tickets", TicketController, :index
    get "/tickets/new", TicketController, :new
    get "/knowledges", KnowledgeController, :index
    get "/announcements", AnnouncementController, :index
    get "/affiliate", AffiliateController, :index

    # Subscription
    get "/services", ServiceController, :index
    get "/services/:sub_id", ServiceController, :details
    get "/subscriptions/:sub_id/usage", TrafficController, :sub_usage
    get "/subscriptions/:sub_id/node-stats", TrafficController, :sub_node_stats
    get "/subscriptions/:sub_id/export", TrafficController, :sub_export

    # Checkout
    get "/checkout/sub/new", CheckoutController, :new_sub
    get "/checkout/sub/renew", CheckoutController, :renew_sub
    get "/checkout/sub/upgrade", CheckoutController, :upgrade_sub
    get "/checkout/sub/reset-quota", CheckoutController, :reset_quota
    get "/checkout/addon", CheckoutController, :addon
    get "/checkout/topup", CheckoutController, :topup

    # Order
    post "/order/create", OrderController, :create
    get "/order/status", OrderController, :status
    get "/order/success", OrderController, :success
    get "/order/cancel", OrderController, :cancel

    # Marketing
    post "/check-ins", CheckinController, :create
  end

  scope "/", HakkawineWeb do
    pipe_through [:user_browser]

    live_session :user_app,
      layout: {HakkawineWeb.Layouts, :app},
      on_mount: [
        {FetchCurrentUser, :fetch_current_user}
      ] do
      live "/account", UserAccountLive.Index, :index
    end
  end

  # scope "/__internal_system_admin_panel__", HakkawineWeb do
  #   pipe_through [:admin_browser]
  #
  #   live_session :admin_app, layout: {HakkawineWeb.Layouts, :admin} do
  #
  #   end
  # end

  # Public API
  scope "/api/v1", HakkawineWeb.Api.V1 do
    pipe_through :api

    post "/payments/notify/:driver", PaymentsController, :notify
    get "/sub/:sub_id/:sub_uuid", SubscriptionController, :index
  end

  # Dev Tools
  if Application.compile_env(:hakkawine, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser_base

      live_dashboard "/dashboard", metrics: HakkawineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
