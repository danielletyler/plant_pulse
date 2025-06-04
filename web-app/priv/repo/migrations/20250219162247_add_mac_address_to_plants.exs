defmodule PlantPulse.Repo.Migrations.AddMacAddressToPlants do
  use Ecto.Migration

  def change do
    alter table(:plants) do
      add(:mac_address, :string)
    end
  end
end
