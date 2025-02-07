defmodule PlantPulseWeb.SensorsJSON do
  alias PlantPulse.Sensors.Sensor

  def index(%{sensors: sensors}) do
    %{data: for(sensor <- sensors, do: data(sensor))}
  end

  def show(%{sensor: sensor}) do
    %{data: data(sensor)}
  end

  defp data(%Sensor{} = datum) do
    %{
      type: datum.type,
      plant_id: datum.plant_id
    }
  end
end
