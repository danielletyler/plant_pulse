defmodule PlantPulse.Periodic do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    Tortoise311.publish("plant_pulse_client", "esp32/photocell", "READ")
    Tortoise311.publish("plant_pulse_client", "esp32/dht11", "READ")
    Tortoise311.publish("plant_pulse_client", "esp32/sm_sensor", "READ")

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, :timer.minutes(1))
  end
end
