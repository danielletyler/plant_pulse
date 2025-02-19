defmodule PlantPulseWeb.PlantsLive do
  alias PlantPulse.Plants.Plant
  use PlantPulseWeb, :live_view

  import SaladUI.Button
  import SaladUI.Form

  alias PlantPulse.Plants

  def mount(_params, _session, socket) do
    plants = Plants.list_plants()

    {:ok, assign(socket, plants: plants, changeset: Plants.change_plant(%Plant{}))}
  end

  def handle_event("save-new", %{"plant" => plant_params}, socket) do
    case Plants.create_plant(plant_params) do
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

  def render(assigns) do
    ~H"""
    <div>
      <.button phx-click={show_modal_core("new-plant-modal")} variant="outline">
        New Plant
      </.button>
    </div>
    <.button :for={plant <- @plants} phx-click={JS.navigate(~p"/plants/#{plant.id}")}>
      <%= plant.name %>
    </.button>

    <.modal id="new-plant-modal" on_cancel={JS.push("reset-new-plant")}>
      <.form :let={f} for={@changeset} phx-submit="save-new" class="w-2/3 space-y-6">
        <.form_item>
          <.form_label error={not Enum.empty?(f[:name].errors)}>Name</.form_label>
          <.input field={f[:name]} type="text" phx-debounce="500" />
        </.form_item>
        <.form_item>
          <.form_label error={not Enum.empty?(f[:species].errors)}>Species</.form_label>
          <.input field={f[:species]} type="text" phx-debounce="500" />
        </.form_item>
        <.form_item>
          <.form_label error={not Enum.empty?(f[:mac_address].errors)}>ESP32 MAC Address</.form_label>
          <.input field={f[:mac_address]} type="text" phx-debounce="500" />
        </.form_item>
        <.button type="submit">Submit</.button>
      </.form>
    </.modal>
    """
  end
end
