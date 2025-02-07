defmodule PlantPulseWeb.SensorsController do
  use PlantPulseWeb, :controller

  alias PlantPulse.Sensors

  def create(conn, %{"data" => data}) do
    {:ok, new_sensor} = Sensors.create_sensor(data)
    render(conn, :show, sensor: new_sensor)
  end
end
