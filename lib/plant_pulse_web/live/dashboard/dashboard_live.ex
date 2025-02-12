defmodule PlantPulseWeb.Dashboard.DashboardLive do
  use PlantPulseWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe("sensor")
    {:ok, assign(socket, led_state: "off", ldr_value: 0)}
  end

  def handle_event("turn_on", _params, socket) do
    PlantPulseWeb.Endpoint.broadcast!("led:lobby", "toggle_led", %{"state" => "ON"})

    {:noreply, assign(socket, led_state: "on")}
  end

  def handle_event("turn_off", _params, socket) do
    PlantPulseWeb.Endpoint.broadcast!("led:lobby", "toggle_led", %{"state" => "OFF"})

    {:noreply, assign(socket, led_state: "off")}
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
