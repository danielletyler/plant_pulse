defmodule PlantPulse.Repo.Migrations.Sensors do
  use Ecto.Migration

  def change do
    create table(:sensors) do
      add :type, :string
      add :plant_id, references("plants", type: :integer), null: false
      timestamps()
    end
  end
end
