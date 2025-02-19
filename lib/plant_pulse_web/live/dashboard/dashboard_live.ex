defmodule PlantPulseWeb.Dashboard.DashboardLive do
  use PlantPulseWeb, :live_view

  alias PlantPulse.Plants.Plant
  alias PlantPulse.Plants

  def mount(%{"id" => plant_id}, _session, socket) do
    plant = Plants.get_plant!(plant_id)
    if connected?(socket), do: PlantPulseWeb.Endpoint.subscribe(plant.mac_address)

    changeset = Plants.change_plant(%Plant{})

    {:ok,
     assign(socket,
       plant: plant,
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

  def handle_event("read_all", _, %{assigns: %{plant: %{mac_address: mac}}} = socket) do
    Tortoise311.publish("plant_pulse_client", "#{mac}/photocell", "READ")
    Tortoise311.publish("plant_pulse_client", "#{mac}/dht11", "READ")
    Tortoise311.publish("plant_pulse_client", "#{mac}/sm_sensor", "READ")

    {:noreply, socket}
  end

  def handle_event(
        "read",
        %{"sensor" => sensor},
        %{assigns: %{plant: %{mac_address: mac}}} = socket
      ) do
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

  def render(assigns) do
    ~H"""
    <div>
      <.header><%= @plant.name %></.header>

      <div class="p-6">
        <.button class="mb-2" phx-click="read_all">Read All</.button>
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          <div class="bg-white shadow-md rounded-lg p-4 border border-gray-200 flex flex-col items-center">
            <div class="text-lg font-semibold">Light Sensor</div>
            <div class="text-gray-600">Value: <%= @ldr_value %></div>
            <div class="text-gray-400 text-xs mt-1">As of 4:48pm</div>
            <button class="mt-4" phx-click="read" phx-value-sensor="photocell">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="w-6 h-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"
                />
              </svg>
            </button>
          </div>
          <div class="bg-white shadow-md rounded-lg p-4 border border-gray-200 flex flex-col items-center">
            <div class="text-lg font-semibold">Humidity</div>
            <div class="text-gray-600">Value: <%= @humi_value %></div>
            <div class="text-gray-400 text-xs mt-1">As of 4:48pm</div>
            <button class="mt-4" phx-click="read" phx-value-sensor="dht11">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="w-6 h-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"
                />
              </svg>
            </button>
          </div>
          <div class="bg-white shadow-md rounded-lg p-4 border border-gray-200 flex flex-col items-center">
            <div class="text-lg font-semibold">Temperature</div>
            <div class="text-gray-600">Value: <%= @temp_value %></div>
            <div class="text-gray-400 text-xs mt-1">As of 4:48pm</div>
            <button class="mt-4" phx-click="read" phx-value-sensor="dht11">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="w-6 h-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"
                />
              </svg>
            </button>
          </div>
          <div class="bg-white shadow-md rounded-lg p-4 border border-gray-200 flex flex-col items-center">
            <div class="text-lg font-semibold">Soil Moisture</div>
            <div class="text-gray-600">Value: <%= @sm_value %></div>
            <div class="text-gray-400 text-xs mt-1">As of 4:48pm</div>
            <button class="mt-4" phx-click="read" phx-value-sensor="sm_sensor">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="w-6 h-6"
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
    """
  end
end
