defmodule PlantPulse.ReadingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PlantPulse.Readings` context.
  """

  @doc """
  Generate a reading.
  """
  def reading_fixture(attrs \\ %{}) do
    {:ok, reading} =
      attrs
      |> Enum.into(%{

      })
      |> PlantPulse.Readings.create_reading()

    reading
  end
end
