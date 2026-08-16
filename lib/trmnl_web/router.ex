defmodule TrmnlWeb.Router do
  use TrmnlWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TrmnlWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug :set_session_ip
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TrmnlWeb do
    pipe_through :browser

    get "/", PageController, :home

    get "/screens/:api_key", ScreenController, :show


    live "/dashboard", DashboardLive.Index, :index

    live "/devices", DeviceLive.Index, :index
    live "/devices/new", DeviceLive.Index, :new
    live "/devices/:id/edit", DeviceLive.Index, :edit

    live "/devices/:id", DeviceLive.Show, :show
    live "/devices/:id/show/edit", DeviceLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  scope "/api", TrmnlWeb do
    pipe_through :api

    get "/setup", APIController, :setup
    get "/display", APIController, :display
    post "/log", APIController, :log
  end

  defp set_session_ip(conn, _opts) do
    ip = to_string(:inet.ntoa(conn.remote_ip))
    host = conn.host

    conn
    |> Plug.Conn.put_session("ip", ip)
    |> Plug.Conn.put_session("host", host)
  end

end
