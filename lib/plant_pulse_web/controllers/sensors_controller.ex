defmodule PlantPulseWeb.SensorsController do
  use PlantPulseWeb, :controller

  alias PlantPulse.Sensors

  def index(conn, _) do
    sensors = Sensors.list_sensors()
    render(conn, :index, sensors: sensors)
  end

  def show(conn, %{"id" => id}) do
    sensor = Sensors.get_sensor!(id)
    render(conn, :show, sensor: sensor)
  end

  def create(conn, %{"data" => data}) do
    {:ok, new_sensor} = Sensors.create_sensor(data)
    render(conn, :show, sensor: new_sensor)
  end
end
