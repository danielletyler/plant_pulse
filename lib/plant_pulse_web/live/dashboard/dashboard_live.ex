defmodule PlantPulseWeb.Dashboard.DashboardLive do
  use PlantPulseWeb, :live_view

  import SaladUI.Button

  alias PlantPulse.Plants.Plant
  alias PlantPulse.Plants

  def mount(%{"id" => plant_id}, _session, socket) do
    mac = Plants.get_plant!(plant_id).mac_address
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe(mac)

    changeset = Plants.change_plant(%Plant{})

    {:ok,
     assign(socket,
       mac: mac,
       new_changeset: changeset,
       show_new_modal: false,
       ldr_value: 0,
       humi_value: 0,
       temp_value: 0,
       sm_value: 0
     )}
  end

  def handle_event("validate", %{"plant" => params}, socket) do
    changeset =
      %Plant{}
      |> Plants.change_plant(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :new_changeset, changeset)}
  end

  def handle_event("read_all", _, %{assigns: %{mac: mac}} = socket) do
    Tortoise311.publish("plant_pulse_client", "#{mac}/photocell", "READ")
    Tortoise311.publish("plant_pulse_client", "#{mac}/dht11", "READ")
    Tortoise311.publish("plant_pulse_client", "#{mac}/sm_sensor", "READ")

    {:noreply, socket}
  end

  def handle_event("read", %{"sensor" => sensor}, %{assigns: %{mac: mac}} = socket) do
    Tortoise311.publish("plant_pulse_client", "#{mac}/#{sensor}", "READ")

    {:noreply, socket}
  end

  def handle_info(%{event: "light", payload: %{value: value}}, socket) do
    {:noreply, assign(socket, ldr_value: value)}
  end

  def handle_info(%{event: "humidity", payload: %{value: value}}, socket) do
    {:noreply, assign(socket, humi_value: value)}
  end

  def handle_info(%{event: "temp", payload: %{value: value}}, socket) do
    {:noreply, assign(socket, temp_value: value)}
  end

  def handle_info(%{event: "soil_moisture", payload: %{value: value}}, socket) do
    {:noreply, assign(socket, sm_value: value)}
  end
end
