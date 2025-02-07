defmodule PlantPulse.Sensors.Sensor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sensors" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, [])
    |> validate_required([])
  end
end
