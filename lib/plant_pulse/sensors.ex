defmodule PlantPulse.Sensors do
  @moduledoc """
  The Sensors context.
  """

  import Ecto.Query, warn: false
  alias PlantPulse.Repo

  alias PlantPulse.Sensors.Sensor

  @doc """
  Returns the list of sensors.

  ## Examples

      iex> list_sensors()
      [%Sensor{}, ...]

  """
  def list_sensors do
    Repo.all(Sensor)
  end

  @doc """
  Gets a single sensor.

  Raises `Ecto.NoResultsError` if the Sensor does not exist.

  ## Examples

      iex> get_sensor!(123)
      %Sensor{}

      iex> get_sensor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sensor!(id), do: Repo.get!(Sensor, id)

  @doc """
  Gets sensors for plant.
  """
  def get_by_plant(plant_id) do
    Sensor
    |> where([s], s.plant_id == ^plant_id)
    |> Repo.all()
  end

  def get_by_mac(mac, type) do
    Sensor
    |> join(:inner, [s], p in assoc(s, :plant))
    |> where([_s, p], p.mac_address == ^mac)
    |> where([s, p], s.type == ^type)
    |> Repo.one()
  end

  @doc """
  Creates a sensor.

  ## Examples

      iex> create_sensor(%{field: value})
      {:ok, %Sensor{}}

      iex> create_sensor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sensor(attrs \\ %{}) do
    %Sensor{}
    |> Sensor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sensor.

  ## Examples

      iex> update_sensor(sensor, %{field: new_value})
      {:ok, %Sensor{}}

      iex> update_sensor(sensor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sensor(%Sensor{} = sensor, attrs) do
    sensor
    |> Sensor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sensor.

  ## Examples

      iex> delete_sensor(sensor)
      {:ok, %Sensor{}}

      iex> delete_sensor(sensor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sensor(%Sensor{} = sensor) do
    Repo.delete(sensor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sensor changes.

  ## Examples

      iex> change_sensor(sensor)
      %Ecto.Changeset{data: %Sensor{}}

  """
  def change_sensor(%Sensor{} = sensor, attrs \\ %{}) do
    Sensor.changeset(sensor, attrs)
  end

  def reading_type_to_sensor("light"), do: :photocell
  def reading_type_to_sensor("humidity"), do: :dht11
  def reading_type_to_sensor("temp"), do: :dht11
  def reading_type_to_sensor("soil_moisture"), do: :sm_sensor
end
