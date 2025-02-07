defmodule PlantPulseWeb.Router do
  use PlantPulseWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PlantPulseWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlantPulseWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", PlantPulseWeb do
    pipe_through :api
    get "/plants", PlantsController, :index
    get "/plants/:id", PlantsController, :show
    post "/plants", PlantsController, :create

    get "/plants/:plant_id/sensors", SensorsController, :list_for_plant
    get "/sensors", SensorsController, :index
    get "/sensors/:id", SensorsController, :show
    post "/sensors", SensorsController, :create

    get "/sensors/:sensor_id/readings", ReadingsController, :list_for_sensor
    get "/plants/:plant_id/readings", ReadingsController, :list_for_plant
    get "/readings", ReadingsController, :index
    get "/readings/:id", ReadingsController, :show
    post "/readings", ReadingsController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlantPulseWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:plant_pulse, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PlantPulseWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
