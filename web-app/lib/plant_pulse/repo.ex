defmodule PlantPulse.Repo do
  use Ecto.Repo,
    otp_app: :plant_pulse,
    adapter: Ecto.Adapters.Postgres
end
