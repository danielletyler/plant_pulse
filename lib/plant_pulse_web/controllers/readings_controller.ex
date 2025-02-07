defmodule PlantPulseWeb.ReadingsController do
  use PlantPulseWeb, :controller

  alias PlantPulse.Readings

  def index(conn, _) do
    readings = Readings.list_readings()
    render(conn, :index, readings: readings)
  end

  def show(conn, %{"id" => id}) do
    reading = Readings.get_reading!(id)
    render(conn, :show, reading: reading)
  end

  def create(conn, %{"data" => data}) do
    {:ok, new_reading} = Readings.create_reading(data)
    render(conn, :show, reading: new_reading)
  end
end
