defmodule PlantPulse.Sensors.Sensor do
  use Ecto.Schema

  import Ecto.Changeset

  alias PlantPulse.Readings.Reading
  alias PlantPulse.Plants.Plant

  schema "sensors" do
    field(:type, Ecto.Enum, values: [:photocell, :dht11_humi, :dht11_temp, :sm_sensor])
    field(:min_threshold, :float)
    field(:max_threshold, :float)
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

  def threshold_changeset(sensor, attrs \\ %{}) do
    sensor
    |> cast(attrs, [:min_threshold, :max_threshold])
  end
end
