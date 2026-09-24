defmodule HakkawineWeb.Router do
  use HakkawineWeb, :router

  alias HakkawineWeb.Plugs.FetchCurrentUser
  alias HakkawineWeb.Plugs.EnsureAuthenticated
  alias HakkawineWeb.Plugs.RedirectIfAuthenticated

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HakkawineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug FetchCurrentUser
  end

  scope "/", HakkawineWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/auth", HakkawineWeb do
    pipe_through [:browser, RedirectIfAuthenticated]

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
    pipe_through [:browser, EnsureAuthenticated]

    delete "/log_out", AuthController, :log_out
  end

  scope "/", HakkawineWeb do
    pipe_through [:browser, EnsureAuthenticated]

    get "/plan/list", PlanController, :index

    get "/checkout/sub/new", CheckoutController, :new_sub
    get "/checkout/sub/renew", CheckoutController, :renew_sub
    get "/checkout/sub/upgrade", CheckoutController, :upgrade_sub
    get "/checkout/sub/reset-quota", CheckoutController, :reset_quota
    get "/checkout/addon", CheckoutController, :addon
    get "/checkout/topup", CheckoutController, :topup

    post "/order/create", OrderController, :create
    get "/order/status", OrderController, :status
    get "/order/success", OrderController, :success
    get "/order/cancel", OrderController, :cancel
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", HakkawineWeb.Api.V1, as: :api_v1 do
    pipe_through :api

    post "/payment/notify", PaymentController, :notify
  end

  if Application.compile_env(:hakkawine, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HakkawineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
