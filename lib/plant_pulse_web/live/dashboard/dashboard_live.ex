defmodule PlantPulseWeb.Dashboard.DashboardLive do
  use PlantPulseWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe("sensor")
    {:ok, assign(socket, led_state: "off", ldr_value: 0)}
  end

  def handle_event("read", _params, socket) do
    Tortoise311.publish("plant_pulse_client", "esp32/receive", "READ")

    {:noreply, assign(socket, led_state: "on")}
  end

  def handle_info(
        %{
          topic: "sensor",
          event: "update",
          payload: %{ldr_value: value}
        },
        socket
      ) do
    IO.inspect("handle info sensor update")
    {:noreply, assign(socket, ldr_value: value)}
  end
end
