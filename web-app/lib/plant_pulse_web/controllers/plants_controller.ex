defmodule PlantPulseWeb.PlantsController do
  use PlantPulseWeb, :controller

  alias PlantPulse.Plants

  def index(conn, _) do
    plants = Plants.list_plants()
    render(conn, :index, plants: plants)
  end

  def show(conn, %{"id" => id}) do
    plant = Plants.get_plant!(id)
    render(conn, :show, plant: plant)
  end

  def create(conn, %{"data" => data}) do
    {:ok, new_plant} = Plants.create_plant(data)
    render(conn, :show, plant: new_plant)
  end
end
