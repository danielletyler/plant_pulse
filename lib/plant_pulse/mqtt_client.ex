defmodule PlantPulse.MQTTClient do
  use Tortoise311.Handler

  @topic "esp32/ir_sensor"

  def child_spec(_opts) do
    IO.inspect("child spec")

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[]]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_opts) do
    IO.inspect("start link")

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
           subscriptions: [{"esp32/ir_sensor", 0}]
         ) do
      {:ok, pid} ->
        IO.inspect("Tortoise client started successfully")
        {:ok, pid}

      {:error, reason} ->
        IO.inspect("Tortoise client failed to start: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def init(_opts) do
    IO.inspect("init")
    {:ok, %{}}
  end

  def handle_message(_topic, payload, state) do
    # Broadcast MQTT message to LiveView
    IO.inspect("handle message")
    PlantPulseWeb.Endpoint.broadcast("sensor", "update", %{ldr_value: payload})
    {:ok, state}
  end
end
