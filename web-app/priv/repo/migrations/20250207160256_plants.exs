defmodule PlantPulse.Repo.Migrations.Plants do
  use Ecto.Migration

  def change do
    create table(:plants) do
      add :name, :string
      add :species, :string
      timestamps()
    end
  end
end
