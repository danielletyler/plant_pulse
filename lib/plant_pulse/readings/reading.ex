defmodule PlantPulse.Readings.Reading do
  use Ecto.Schema
  import Ecto.Changeset

  schema "readings" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [])
    |> validate_required([])
  end
end
