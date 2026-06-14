defmodule EcoHabits.Habits.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "habits" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :points, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(habit, attrs, user_scope) do
    habit
    |> cast(attrs, [:name, :description, :category, :points])
    |> validate_required([:name, :description, :category, :points])
    |> put_change(:user_id, user_scope.user.id)
  end
end
