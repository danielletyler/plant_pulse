defmodule PlantPulse.Repo.Migrations.Readings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :value, :float
      add :sensor_id, references("sensors", type: :integer), null: false
      timestamps()
    end
  end
end
