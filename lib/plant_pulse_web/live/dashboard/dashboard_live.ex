defmodule PlantPulseWeb.Dashboard.DashboardLive do
  alias PlantPulse.Sensors.Sensor
  alias PlantPulse.Sensors
  alias PlantPulse.Readings
  alias PlantPulse.Plants

  use PlantPulseWeb, :live_view

  def mount(%{"id" => plant_id}, _session, socket) do
    plant = Plants.get_plant!(plant_id)
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe(plant.device_id)

    readings = Readings.get_most_recent_readings_for_plant(plant_id)

    {:ok,
     assign(socket,
       plant: plant,
       show_new_modal: false,
       show_modal: false,
       readings: readings,
       ldr_value: 0,
       humi_value: 0,
       temp_value: 0,
       sm_value: 0,
       changeset: Sensor.threshold_changeset(%Sensor{})
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

  def handle_event("open-modal", %{"sensor-id" => sensor_id}, socket) do
    sensor = Sensors.get_sensor!(sensor_id)
    changeset = Sensor.threshold_changeset(sensor)

    {:noreply, assign(socket, %{modal_sensor: sensor, show_modal: true, changeset: changeset})}
  end

  def handle_event("close-modal", _, socket),
    do: {:noreply, assign(socket, show_modal: false)}

  def handle_event("save-thresholds", attrs, socket) do
    %{"sensor" => thresh_attrs} = attrs
    %{assigns: %{modal_sensor: sensor}} = socket
    Sensors.update_thresholds(sensor, thresh_attrs)
    {:noreply, assign(socket, show_modal: false)}
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
            class={"#{if reading_in_threshold?(reading), do: "bg-white", else: "bg-red-100"} shadow-lg rounded-lg p-5 flex flex-col"}
          >
            <div class="w-full h-full flex items-start justify-end"></div>
            <div
              as="button"
              class="flex justify-end  hover:cursor-pointer"
              phx-click="open-modal"
              phx-value-sensor-id={reading.sensor_id}
            >
              <Heroicons.icon name="wrench-screwdriver" type="outline" class="h-3 w-3" />
            </div>
            <div class="text-lg font-semibold"><%= sensor_title(reading.value_type) %></div>
            <div class="flex">
              <div class="text-gray-600">Value: <%= get_value(reading) %></div>
              <div :if={reading.value_type == "soil_moisture"}>%</div>
            </div>
            <div class="flex">
              <div class="text-gray-400 text-xs mt-1">
                <%= format(reading.inserted_at) %>
              </div>
              <div
                as="button"
                class="flex justify-end hover:cursor-pointer"
                phx-click="read"
                phx-value-sensor={reading_type_to_sensor(reading.value_type)}
              >
                <Heroicons.icon name="arrow-path" type="outline" class="h-4 w-4" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <.new_modal id="plant-settings-modal" show={@show_modal} close_modal="close-modal">
      <.form :let={f} for={@changeset} phx-submit="save-thresholds" class="w-2/3 space-y-6">
        <.input field={f[:min_threshold]} type="number" phx-debounce="500" label="Min" />
        <.input field={f[:max_threshold]} type="number" phx-debounce="500" label="Max" />
        <.button type="submit">Submit</.button>
      </.form>
    </.new_modal>
    """
  end

  defp get_value(%{value_type: "soil_moisture", value: value}) do
    val = ((3000 - value) / (3000 - 900) * 100) |> trunc()
    min(100, max(0, val))
  end

  defp get_value(reading) do
    reading.value
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

  defp reading_in_threshold?(reading) do
    %{min_threshold: min, max_threshold: max} = Sensors.get_sensor!(reading.sensor_id)

    value = get_value(reading)

    greater_than_min = !min || value > min
    lesser_than_max = !max || value < max

    greater_than_min && lesser_than_max
  end
end
