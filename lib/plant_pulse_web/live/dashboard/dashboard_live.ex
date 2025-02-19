defmodule PlantPulseWeb.Dashboard.DashboardLive do
  use PlantPulseWeb, :live_view

  import SaladUI.Button
  import SaladUI.Form

  alias PlantPulse.Plants.Plant
  alias PlantPulse.Plants

  def mount(_params, _session, socket) do
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe("14:2B:2F:D9:4C:18")

    changeset = Plants.change_plant(%Plant{})

    {:ok,
     assign(socket,
       new_changeset: changeset,
       show_new_modal: false,
       ldr_value: 0,
       humi_value: 0,
       temp_value: 0,
       sm_value: 0
     )}
  end

  def handle_event("reset-new-plant", _, socket) do
    changeset = Plants.change_plant(%Plant{})
    {:noreply, assign(socket, new_changeset: changeset)}
  end

  def handle_event("validate", %{"plant" => params}, socket) do
    changeset =
      %Plant{}
      |> Plants.change_plant(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :new_changeset, changeset)}
  end

  def handle_event("save-new", %{"plant" => plant_params}, socket) do
    case Plants.create_plant(plant_params) do
      {:ok, _plant} ->
        {:noreply,
         socket
         |> assign(new_changeset: Plants.change_plant(%Plant{}))
         |> put_flash(:info, "Plant created successfully!")
         |> push_navigate(to: ~p"/dashboard")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, new_changeset: changeset)}
    end
  end

  def handle_event("read_all", _, socket) do
    # get plant.mac_address from socket
    Tortoise311.publish("plant_pulse_client", "14:2B:2F:D9:4C:18/photocell", "READ")
    Tortoise311.publish("plant_pulse_client", "14:2B:2F:D9:4C:18/dht11", "READ")
    Tortoise311.publish("plant_pulse_client", "14:2B:2F:D9:4C:18/sm_sensor", "READ")

    {:noreply, socket}
  end

  def handle_event("read", %{"sensor" => sensor}, socket) do
    Tortoise311.publish("plant_pulse_client", "14:2B:2F:D9:4C:18/#{sensor}", "READ")

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
