defmodule PlantPulse.Sensors.Sensor do
  use Ecto.Schema

  import Ecto.Changeset

  alias PlantPulse.Readings.Reading
  alias PlantPulse.Plants.Plant

  schema "sensors" do
    field(:type, Ecto.Enum, values: [:photocell, :dht11, :sm_sensor])
    belongs_to(:plant, Plant)
    has_many(:readings, Reading)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sensor, attrs) do
    sensor
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
