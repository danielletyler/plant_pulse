defmodule PlantPulse.Plants.Plant do
  use Ecto.Schema

  import Ecto.Changeset

  alias PlantPulse.Sensors.Sensor

  schema "plants" do
    field(:name, :string)
    field(:species, :string)
    field(:device_id, :string)
    has_many(:sensors, Sensor)

    timestamps(type: :utc_datetime)
  end

  @attrs [
    :name,
    :species,
    :device_id
  ]

  @required [
    :name,
    :device_id
  ]

  @doc false
  def changeset(plant, attrs) do
    plant
    |> cast(attrs, @attrs)
    |> cast_assoc(:sensors, with: &PlantPulse.Sensors.Sensor.changeset/2)
    |> validate_required(@required)
  end
end
