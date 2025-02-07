defmodule PlantPulse.SensorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PlantPulse.Sensors` context.
  """

  @doc """
  Generate a sensor.
  """
  def sensor_fixture(attrs \\ %{}) do
    {:ok, sensor} =
      attrs
      |> Enum.into(%{

      })
      |> PlantPulse.Sensors.create_sensor()

    sensor
  end
end
