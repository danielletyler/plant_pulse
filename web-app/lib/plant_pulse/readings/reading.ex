defmodule PlantPulse.Readings.Reading do
  alias PlantPulse.Sensors.Sensor
  use Ecto.Schema
  import Ecto.Changeset

  schema "readings" do
    field(:value, :float)
    field(:value_type, :string)
    belongs_to(:sensor, Sensor)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:value, :value_type, :sensor_id])
    |> validate_required([:value, :sensor_id])
  end
end
