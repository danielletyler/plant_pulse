defmodule PlantPulseWeb.ReadingsJSON do
  alias PlantPulse.Readings.Reading

  def index(%{readings: readings}) do
    %{data: for(reading <- readings, do: data(reading))}
  end

  def show(%{reading: reading}) do
    %{data: data(reading)}
  end

  defp data(%Reading{} = datum) do
    %{
      value: datum.value,
      sensor_id: datum.sensor_id
    }
  end
end
