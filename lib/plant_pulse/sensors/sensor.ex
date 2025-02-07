defmodule PlantPulse.Sensors.Sensor do
  use Ecto.Schema

  import Ecto.Changeset

  alias PlantPulse.Readings.Reading
  alias PlantPulse.Plants.Plant

  schema "sensors" do
    field(:type, Ecto.Enum, values: [:moisture, :temperature, :humidity, :light])
    belongs_to(:plant, Plant)
    has_many(:readings, Reading)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, [:type, :plant_id])
    |> validate_required([:type, :plant_id])
  end
end
