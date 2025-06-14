defmodule PlantPulse.MQTTClient do
  alias PlantPulse.Readings
  alias PlantPulse.Sensors
  use Tortoise311.Handler

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[]]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_opts) do
    case Tortoise311.Supervisor.start_child(
           client_id: "plant_pulse_client",
           handler: {__MODULE__, []},
           server: {
             Tortoise311.Transport.SSL,
             host: "********",
             port: 8883,
             opts: [
               # Use this only for testing; remove in production
               {:verify, :verify_none},
               {:depth, 3}
             ]
           },
           user_name: "*******",
           password: "*******",
           subscriptions: [
             {"+/light", 0},
             {"+/humidity", 0},
             {"+/temp", 0},
             {"+/soil_moisture", 0}
           ]
         ) do
      {:ok, pid} ->
        IO.inspect("Tortoise client started successfully")
        {:ok, pid}

      {:error, reason} ->
        IO.inspect("Tortoise client failed to start: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def init(_opts), do: {:ok, %{}}

  def handle_message([device_id, type], value, state) do
    # use device id and type to get sensor_id through plant
    sensor = Sensors.get_by_device(device_id, Sensors.reading_type_to_sensor(type))

    Readings.create_reading(%{value: String.trim(value), value_type: type, sensor_id: sensor.id})

    PlantPulseWeb.Endpoint.broadcast(device_id, "update", %{})
    {:ok, state}
  end
end
