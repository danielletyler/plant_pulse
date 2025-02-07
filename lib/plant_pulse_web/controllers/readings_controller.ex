defmodule PlantPulseWeb.ReadingsController do
  use PlantPulseWeb, :controller

  alias PlantPulse.Readings

  def create(conn, %{"data" => data}) do
    {:ok, new_reading} = Readings.create_reading(data)
    render(conn, :show, reading: new_reading)
  end
end
