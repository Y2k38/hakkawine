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

    get "/plan/list", PlanController, :list
    get "/checkout/plans/:code", CheckoutController, :plan_page
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

  if Application.compile_env(:hakkawine, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HakkawineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
