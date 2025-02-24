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
    Tortoise311.publish("plant_pulse_client", "periodic/photocell", "READ")
    Tortoise311.publish("plant_pulse_client", "periodic/dht11_humi", "READ")
    Tortoise311.publish("plant_pulse_client", "periodic/dht11_temp", "READ")
    Tortoise311.publish("plant_pulse_client", "periodic/sm_sensor", "READ")

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, :timer.hours(1))
  end
end
