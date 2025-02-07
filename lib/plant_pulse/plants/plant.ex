defmodule PlantPulse.Plants.Plant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plants" do
    field(:name, :string)
    field(:species, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plant, attrs) do
    plant
    |> cast(attrs, [:name, :species])
    |> validate_required([:name])
  end
end
