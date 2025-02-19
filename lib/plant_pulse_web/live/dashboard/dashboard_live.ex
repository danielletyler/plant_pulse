defmodule PlantPulseWeb.Dashboard.DashboardLive do
  use PlantPulseWeb, :live_view

  import SaladUI.Button
  import SaladUI.Dialog
  import SaladUI.Label
  import SaladUI.Form

  alias PlantPulse.Plants.Plant
  alias PlantPulse.Plants

  def mount(_params, _session, socket) do
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe("sensors")

    new_changeset = Plant.changeset(%Plant{}, %{})

    {:ok,
     assign(socket,
       new_changeset: new_changeset,
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

  def handle_event("save-new", %{"plant" => plant_params}, socket) do
    case Plants.create_plant(plant_params) do
      {:ok, _plant} ->
        IO.inspect("here")

        {:noreply,
         socket
         |> assign(new_changeset: Plant.changeset(%Plant{}, %{}))
         |> put_flash(:info, "Plant created successfully!")
         |> push_navigate(to: ~p"/dashboard")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, new_changeset: changeset)}
    end
  end

  def handle_event("read_all", _, socket) do
    Tortoise311.publish("plant_pulse_client", "esp32/photocell", "READ")
    Tortoise311.publish("plant_pulse_client", "esp32/dht11", "READ")
    Tortoise311.publish("plant_pulse_client", "esp32/sm_sensor", "READ")

    {:noreply, socket}
  end

  def handle_event("read", %{"sensor" => sensor}, socket) do
    Tortoise311.publish("plant_pulse_client", sensor, "READ")

    {:noreply, socket}
  end

  def handle_info(%{topic: "sensors", event: "light", payload: payload}, socket) do
    {:noreply, assign(socket, ldr_value: payload)}
  end

  def handle_info(%{topic: "sensors", event: "humidity", payload: payload}, socket) do
    {:noreply, assign(socket, humi_value: payload)}
  end

  def handle_info(%{topic: "sensors", event: "temp", payload: payload}, socket) do
    {:noreply, assign(socket, temp_value: payload)}
  end

  def handle_info(%{topic: "sensors", event: "soil_moisture", payload: payload}, socket) do
    {:noreply, assign(socket, sm_value: payload)}
  end
end
