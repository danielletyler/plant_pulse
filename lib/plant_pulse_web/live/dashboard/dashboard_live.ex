defmodule PlantPulseWeb.Dashboard.DashboardLive do
  use PlantPulseWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe("sensors")
    {:ok, assign(socket, ldr_value: 0, humi_value: 0, temp_value: 0)}
  end

  def handle_event("read", %{"sensor" => sensor}, socket) do
    Tortoise311.publish("plant_pulse_client", sensor, "READ")

    {:noreply, socket}
  end

  def handle_info(%{topic: "sensors", payload: payload}, socket) do
    {:noreply, assign(socket, payload)}
  end
end
