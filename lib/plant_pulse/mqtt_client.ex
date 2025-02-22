defmodule PlantPulse.MQTTClient do
  alias PlantPulse.Sensors.Sensor
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
           #  handler: {Tortoise311.Handler.Logger, []},
           handler: {__MODULE__, []},
           server: {
             Tortoise311.Transport.SSL,
             host: "40c4489d8b17431396e6d975f75207a4.s1.eu.hivemq.cloud",
             port: 8883,
             opts: [
               # Use this only for testing; remove in production
               {:verify, :verify_none},
               {:depth, 3}
             ]
           },
           user_name: "plant-pulse-admin",
           password: "SevenIron1998!",
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

  def handle_message([mac_address, type], value, state) do
    # use mac address and type to get sensor_id through plant
    sensor = Sensors.get_by_mac(mac_address, Sensor.reading_type_to_sensor(type))

    value =
      (sensor.type == :dht111 && is_binary(value) && value |> String.trim() |> String.to_float()) ||
        value

    Readings.create_reading(%{value: value, value_type: type, sensor_id: sensor.id})

    PlantPulseWeb.Endpoint.broadcast(mac_address, "update", %{})
    {:ok, state}
  end
end
