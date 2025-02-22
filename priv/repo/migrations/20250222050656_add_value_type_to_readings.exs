defmodule PlantPulse.Repo.Migrations.AddMacAddressToPlants do
  use Ecto.Migration

  def change do
    alter table(:readings) do
      add(:value_type, :string)
    end
  end
end
