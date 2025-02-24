defmodule PlantPulseWeb.Dashboard.DashboardLive do
  alias PlantPulse.Sensors
  alias PlantPulse.Readings

  use PlantPulseWeb, :live_view

  alias PlantPulse.Plants

  def mount(%{"id" => plant_id}, _session, socket) do
    plant = Plants.get_plant!(plant_id)
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe(plant.device_id)

    readings = Readings.get_most_recent_readings_for_plant(plant_id)

    {:ok,
     assign(socket,
       plant: plant,
       show_new_modal: false,
       readings: readings,
       ldr_value: 0,
       humi_value: 0,
       temp_value: 0,
       sm_value: 0
     )}
  end

  def handle_event("read_all", _, %{assigns: %{plant: %{device_id: device_id}}} = socket) do
    Tortoise311.publish("plant_pulse_client", "#{device_id}/photocell", "READ")
    Tortoise311.publish("plant_pulse_client", "#{device_id}/dht11_temp", "READ")
    Tortoise311.publish("plant_pulse_client", "#{device_id}/dht11_humi", "READ")
    Tortoise311.publish("plant_pulse_client", "#{device_id}/sm_sensor", "READ")

    {:noreply, socket}
  end

  def handle_event(
        "read",
        %{"sensor" => sensor},
        %{assigns: %{plant: %{device_id: device_id}}} = socket
      ) do
    Tortoise311.publish("plant_pulse_client", "#{device_id}/#{sensor}", "READ")

    {:noreply, socket}
  end

  def handle_event("open-thresh-modal", %{"sensor" => sensor_id}, socket) do
    show_modal_core("threshold-modal")

    {:noreply,
     assign(socket, thresh_sensor: sensor_id)
     |> push_event("show_modal", %{id: "threshold-modal"})}
  end

  def handle_event(
        "update-thresh",
        thresh_attrs,
        %{assigns: %{thresh_sensor: sensor_id}} = socket
      ) do
    IO.inspect(thresh_attrs)
    Sensors.get_sensor!(sensor_id) |> Sensors.update_sensor(thresh_attrs)
    {:noreply, socket}
  end

  def handle_info(%{event: "update"}, %{assigns: %{plant: plant}} = socket) do
    readings = Readings.get_most_recent_readings_for_plant(plant.id)
    {:noreply, assign(socket, readings: readings)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @plant.name %>
        <:subtitle>
          <%= @plant.species %>
        </:subtitle>
      </.header>
      <div class="mt-6">
        <.button class="mb-2" phx-click="read_all">Read All</.button>
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          <div
            :for={reading <- @readings}
            class="bg-white shadow-md rounded-lg p-5 border border-gray-200 flex flex-col"
          >
            <div class="w-full h-full flex items-start justify-end">
              <button phx-click="open-thresh-modal" phx-value-sensor={reading.sensor_id}>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="size-6"
                  width="20"
                  height="20"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M10.5 6h9.75M10.5 6a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 6H7.5m3 12h9.75m-9.75 0a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m-3.75 0H7.5m9-6h3.75m-3.75 0a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m-9.75 0h9.75"
                  />
                </svg>
              </button>
            </div>
            <div class="text-lg font-semibold"><%= sensor_title(reading.value_type) %></div>
            <div class="text-gray-600">Value: <%= reading.value %></div>
            <div class="flex">
              <div class="text-gray-400 text-xs mt-1">
                <%= format(reading.inserted_at) %>
              </div>
              <button phx-click="read" phx-value-sensor={reading_type_to_sensor(reading.value_type)}>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="w-4 h-4"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"
                  />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <.modal id="threshold-modal">
      <.form :let={f} for={%{}} phx-submit="update-thresh" class="w-2/3 space-y-6">
        <.input class="mb-2" field={f[:min]} type="text" phx-debounce="500" label="Minimum" />
        <.input class="mb-2" field={f[:max]} type="text" phx-debounce="500" label="Maximum" />
        <.button type="submit">Submit</.button>
      </.form>
    </.modal>
    """
  end

  defp format(datetime) do
    datetime
    |> Timex.to_datetime("America/Chicago")
    |> Timex.format!("%Y/%m/%d at %I:%M%P", :strftime)
  end

  defp sensor_title("light"), do: "Light"
  defp sensor_title("temp"), do: "Temperature"
  defp sensor_title("humidity"), do: "Humidity"
  defp sensor_title("soil_moisture"), do: "Soil Moisture"

  defp reading_type_to_sensor("light"), do: :photocell
  defp reading_type_to_sensor("humidity"), do: :dht11_humi
  defp reading_type_to_sensor("temp"), do: :dht11_temp
  defp reading_type_to_sensor("soil_moisture"), do: :sm_sensor
end
