defmodule PlantPulse.Readings do
  @moduledoc """
  The Readings context.
  """

  import Ecto.Query, warn: false
  alias PlantPulse.Sensors
  alias PlantPulse.Repo

  alias PlantPulse.Readings.Reading

  @doc """
  Returns the list of readings.

  ## Examples

      iex> list_readings()
      [%Reading{}, ...]

  """
  def list_readings do
    Repo.all(Reading)
  end

  @doc """
  Gets a single reading.

  Raises `Ecto.NoResultsError` if the Reading does not exist.

  ## Examples

      iex> get_reading!(123)
      %Reading{}

      iex> get_reading!(456)
      ** (Ecto.NoResultsError)

  """
  def get_reading!(id), do: Repo.get!(Reading, id)

  @doc """
  Gets readings by sensor.
  """
  def get_by_sensor(sensor_id) do
    Reading
    |> where([r], r.sensor_id == ^sensor_id)
    |> Repo.all()
  end

  @doc """
  Gets readings for plant.
  """
  def get_by_plant(plant_id) do
    Reading
    |> join(:inner, [r], s in assoc(r, :sensor))
    |> join(:inner, [_r, s], p in assoc(s, :plant))
    |> where([_r, _s, p], p.id == ^plant_id)
    |> Repo.all()
  end

  def get_most_recent_readings_for_plant(plant_id) do
    Reading
    |> join(:inner, [r], s in assoc(r, :sensor))
    |> join(:inner, [_r, s], p in assoc(s, :plant))
    |> where([_r, _s, p], p.id == ^plant_id)
    |> order_by([r, s, p], desc: r.inserted_at, asc: s.type)
    |> distinct([r, s, p], r.value_type)
    |> select([r, s, p], r)
    |> Repo.all()
  end

  @doc """
  Creates a reading.

  ## Examples

      iex> create_reading(%{field: value})
      {:ok, %Reading{}}

      iex> create_reading(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_reading(attrs \\ %{}) do
    %Reading{}
    |> Reading.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reading.

  ## Examples

      iex> update_reading(reading, %{field: new_value})
      {:ok, %Reading{}}

      iex> update_reading(reading, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_reading(%Reading{} = reading, attrs) do
    reading
    |> Reading.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reading.

  ## Examples

      iex> delete_reading(reading)
      {:ok, %Reading{}}

      iex> delete_reading(reading)
      {:error, %Ecto.Changeset{}}

  """
  def delete_reading(%Reading{} = reading) do
    Repo.delete(reading)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking reading changes.

  ## Examples

      iex> change_reading(reading)
      %Ecto.Changeset{data: %Reading{}}

  """
  def change_reading(%Reading{} = reading, attrs \\ %{}) do
    Reading.changeset(reading, attrs)
  end
end
