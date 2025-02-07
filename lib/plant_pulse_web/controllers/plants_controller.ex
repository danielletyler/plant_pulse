defmodule PlantPulseWeb.PlantsController do
  use PlantPulseWeb, :controller

  alias PlantPulse.Plants

  def create(conn, %{"data" => data}) do
    {:ok, new_plant} = Plants.create_plant(data)
    render(conn, :show, plant: new_plant)
  end
end
