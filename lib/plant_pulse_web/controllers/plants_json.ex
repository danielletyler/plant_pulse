defmodule PlantPulseWeb.PlantsJSON do
  alias PlantPulse.Plants.Plant

  def index(%{plants: plants}) do
    %{data: for(plant <- plants, do: data(plant))}
  end

  def show(%{plant: plant}) do
    %{data: data(plant)}
  end

  defp data(%Plant{} = datum) do
    %{
      name: datum.name,
      species: datum.species
    }
  end
end
