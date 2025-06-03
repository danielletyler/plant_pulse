defmodule PlantPulseWeb.PlantsLive do
  alias PlantPulse.Sensors
  alias PlantPulse.Sensors.Sensor
  alias PlantPulse.Plants.Plant
  use PlantPulseWeb, :live_view

  import Phoenix.HTML.Form

  alias PlantPulse.Plants

  def mount(_params, _session, socket) do
    plants = Plants.list_plants()

    {:ok,
     assign(socket,
       plants: plants,
       show_modal: false,
       changeset: Plants.change_plant(%Plant{sensors: [Sensors.change_sensor(%Sensor{})]})
     )}
  end

  def handle_event("save-new", %{"plant" => plant_params}, socket) do
    %{"sensors" => %{"0" => sensors}} = plant_params

    selected_sensors =
      sensors
      |> Enum.filter(fn {_sensor, value} -> value == "true" end)
      |> Enum.map(fn {type, _value} -> %{"type" => type} end)

    new_plant = %{plant_params | "sensors" => selected_sensors}

    case Plants.create_plant(new_plant) do
      {:ok, _plant} ->
        {:noreply,
         socket
         |> assign(changeset: Plants.change_plant(%Plant{}))
         |> put_flash(:info, "Plant created successfully!")
         |> push_navigate(to: ~p"/plants")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("reset-new-plant", _, socket) do
    changeset = Plants.change_plant(%Plant{})
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("show-modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close-modal", _, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.button class="mb-4" phx-click="show-modal" variant="secondary">
        New Plant
      </.button>
    </div>

    <div class="grid grid-cols-3 gap-4">
      <.clickable_card :for={plant <- @plants} phx-click={JS.navigate(~p"/plants/#{plant.id}")}>
        <div class="p-4">
          <h3 class="text-xl font-semibold text-gray-800"><%= plant.name %></h3>
          <p class="text-gray-600 mt-2">
            This is a description of the card. Maybe this will be an icon or image or overview of last poll.
          </p>
        </div>
      </.clickable_card>
    </div>

    <.modal id="new-plant-modal" show={@show_modal} close_modal="close-modal">
      <.form :let={f} for={@changeset} phx-submit="save-new" class="w-2/3 space-y-6">
        <.input class="mb-2" field={f[:name]} type="text" phx-debounce="500" label="Name" />
        <.input field={f[:species]} type="text" phx-debounce="500" label="Species" />
        <.input field={f[:device_id]} type="text" phx-debounce="500" label="Device ID" />
        <div class="space-y-2">
          <%= inputs_for f, :sensors, fn sensors -> %>
            <.input
              field={sensors[:photocell]}
              label="Photocell"
              type="checkbox"
              class="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            />
            <.input
              field={sensors[:dht11_humi]}
              label="DHT11 Humidity"
              type="checkbox"
              class="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            />
            <.input
              field={sensors[:dht11_temp]}
              label="DHT11 Temperature"
              type="checkbox"
              class="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            />
            <.input
              field={sensors[:sm_sensor]}
              label="SM Sensor"
              type="checkbox"
              class="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            />
          <% end %>
        </div>
        <.button type="submit">Submit</.button>
      </.form>
    </.modal>
    """
  end
end
