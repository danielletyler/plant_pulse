defmodule PlantPulse.Plants.Plant do
  use Ecto.Schema

  import Ecto.Changeset

  alias PlantPulse.Sensors.Sensor

  schema "plants" do
    field(:name, :string)
    field(:species, :string)
    field(:mac_address, :string)
    has_many(:sensors, Sensor)

    timestamps(type: :utc_datetime)
  end

  @attrs [
    :name,
    :species,
    :mac_address
  ]

  @required [
    :name,
    :mac_address
  ]

  @doc false
  def changeset(plant, attrs) do
    plant
    |> cast(attrs, @attrs)
    |> cast_assoc(:sensors, with: &PlantPulse.Sensors.Sensor.changeset/2)
    |> validate_required(@required)
  end
end
