defmodule PlantPulse.PlantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PlantPulse.Plants` context.
  """

  @doc """
  Generate a plant.
  """
  def plant_fixture(attrs \\ %{}) do
    {:ok, plant} =
      attrs
      |> Enum.into(%{

      })
      |> PlantPulse.Plants.create_plant()

    plant
  end
end
