defmodule EcoHabits.Tracking do
  @moduledoc """
  The Tracking context.
  """

  import Ecto.Query, warn: false
  alias EcoHabits.Repo

  alias EcoHabits.Tracking.CheckIn
  alias EcoHabits.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any check_in changes.

  The broadcasted messages match the pattern:

    * {:created, %CheckIn{}}
    * {:updated, %CheckIn{}}
    * {:deleted, %CheckIn{}}

  """
  def subscribe_check_ins(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(EcoHabits.PubSub, "user:#{key}:check_ins")
  end

  defp broadcast_check_in(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(EcoHabits.PubSub, "user:#{key}:check_ins", message)
  end

  @doc """
  Returns the list of check_ins.

  ## Examples

      iex> list_check_ins(scope)
      [%CheckIn{}, ...]

  """
  def list_check_ins(%Scope{} = scope) do
    Repo.all_by(CheckIn, user_id: scope.user.id)
  end

  @doc """
  Gets a single check_in.

  Raises `Ecto.NoResultsError` if the Check in does not exist.

  ## Examples

      iex> get_check_in!(scope, 123)
      %CheckIn{}

      iex> get_check_in!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_check_in!(%Scope{} = scope, id) do
    Repo.get_by!(CheckIn, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a check_in.

  ## Examples

      iex> create_check_in(scope, %{field: value})
      {:ok, %CheckIn{}}

      iex> create_check_in(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_check_in(%Scope{} = scope, attrs) do
    with {:ok, check_in = %CheckIn{}} <-
           %CheckIn{}
           |> CheckIn.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_check_in(scope, {:created, check_in})
      {:ok, check_in}
    end
  end

  @doc """
  Updates a check_in.

  ## Examples

      iex> update_check_in(scope, check_in, %{field: new_value})
      {:ok, %CheckIn{}}

      iex> update_check_in(scope, check_in, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_check_in(%Scope{} = scope, %CheckIn{} = check_in, attrs) do
    true = check_in.user_id == scope.user.id

    with {:ok, check_in = %CheckIn{}} <-
           check_in
           |> CheckIn.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_check_in(scope, {:updated, check_in})
      {:ok, check_in}
    end
  end

  @doc """
  Deletes a check_in.

  ## Examples

      iex> delete_check_in(scope, check_in)
      {:ok, %CheckIn{}}

      iex> delete_check_in(scope, check_in)
      {:error, %Ecto.Changeset{}}

  """
  def delete_check_in(%Scope{} = scope, %CheckIn{} = check_in) do
    true = check_in.user_id == scope.user.id

    with {:ok, check_in = %CheckIn{}} <-
           Repo.delete(check_in) do
      broadcast_check_in(scope, {:deleted, check_in})
      {:ok, check_in}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking check_in changes.

  ## Examples

      iex> change_check_in(scope, check_in)
      %Ecto.Changeset{data: %CheckIn{}}

  """
  def change_check_in(%Scope{} = scope, %CheckIn{} = check_in, attrs \\ %{}) do
    true = check_in.user_id == scope.user.id

    CheckIn.changeset(check_in, attrs, scope)
  end

    def check_in_today(%Scope{} = scope, habit_id) do
    attrs = %{
      "date" => Date.utc_today(),
      "habit_id" => habit_id
    }

    create_check_in(scope, attrs)
  end

  def list_recent_check_ins(%Scope{} = scope) do
    CheckIn
    |> where([c], c.user_id == ^scope.user.id)
    |> order_by([c], desc: c.inserted_at)
    |> limit(10)
    |> Repo.all()
  end
end
