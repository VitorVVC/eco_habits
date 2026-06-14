defmodule EcoHabits.Habits do
  @moduledoc """
  The Habits context.
  """

  import Ecto.Query, warn: false
  alias EcoHabits.Repo

  alias EcoHabits.Habits.Habit
  alias EcoHabits.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any habit changes.

  The broadcasted messages match the pattern:

    * {:created, %Habit{}}
    * {:updated, %Habit{}}
    * {:deleted, %Habit{}}

  """
  def subscribe_habits(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(EcoHabits.PubSub, "user:#{key}:habits")
  end

  defp broadcast_habit(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(EcoHabits.PubSub, "user:#{key}:habits", message)
  end

  @doc """
  Returns the list of habits.

  ## Examples

      iex> list_habits(scope)
      [%Habit{}, ...]

  """
  def list_habits(%Scope{} = scope) do
    Repo.all_by(Habit, user_id: scope.user.id)
  end

  @doc """
  Gets a single habit.

  Raises `Ecto.NoResultsError` if the Habit does not exist.

  ## Examples

      iex> get_habit!(scope, 123)
      %Habit{}

      iex> get_habit!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_habit!(%Scope{} = scope, id) do
    Repo.get_by!(Habit, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a habit.

  ## Examples

      iex> create_habit(scope, %{field: value})
      {:ok, %Habit{}}

      iex> create_habit(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_habit(%Scope{} = scope, attrs) do
    with {:ok, habit = %Habit{}} <-
           %Habit{}
           |> Habit.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_habit(scope, {:created, habit})
      {:ok, habit}
    end
  end

  @doc """
  Updates a habit.

  ## Examples

      iex> update_habit(scope, habit, %{field: new_value})
      {:ok, %Habit{}}

      iex> update_habit(scope, habit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_habit(%Scope{} = scope, %Habit{} = habit, attrs) do
    true = habit.user_id == scope.user.id

    with {:ok, habit = %Habit{}} <-
           habit
           |> Habit.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_habit(scope, {:updated, habit})
      {:ok, habit}
    end
  end

  @doc """
  Deletes a habit.

  ## Examples

      iex> delete_habit(scope, habit)
      {:ok, %Habit{}}

      iex> delete_habit(scope, habit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_habit(%Scope{} = scope, %Habit{} = habit) do
    true = habit.user_id == scope.user.id

    with {:ok, habit = %Habit{}} <-
           Repo.delete(habit) do
      broadcast_habit(scope, {:deleted, habit})
      {:ok, habit}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking habit changes.

  ## Examples

      iex> change_habit(scope, habit)
      %Ecto.Changeset{data: %Habit{}}

  """
  def change_habit(%Scope{} = scope, %Habit{} = habit, attrs \\ %{}) do
    true = habit.user_id == scope.user.id

    Habit.changeset(habit, attrs, scope)
  end
end
