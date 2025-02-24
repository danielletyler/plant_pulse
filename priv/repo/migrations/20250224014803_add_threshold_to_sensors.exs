defmodule PlantPulse.Repo.Migrations.AddThresholdToSensors do
  use Ecto.Migration

  def change do
    alter table(:sensors) do
      add(:min_threshold, :float)
      add(:max_threshold, :float)
    end
  end
end
