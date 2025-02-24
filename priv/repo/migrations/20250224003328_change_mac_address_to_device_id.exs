defmodule PlantPulse.Repo.Migrations.ChangeMacAddressToDeviceId do
  use Ecto.Migration

  def change do
    alter table(:plants) do
      remove(:mac_address, :string)
      add(:device_id, :string)
    end
  end
end
