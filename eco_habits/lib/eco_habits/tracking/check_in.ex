defmodule EcoHabits.Tracking.CheckIn do
  use Ecto.Schema
  import Ecto.Changeset

  schema "check_ins" do
    field :date, :date
    field :habit_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(check_in, attrs, user_scope) do
    check_in
    |> cast(attrs, [:date, :habit_id])
    |> validate_required([:date, :habit_id])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint([:user_id, :habit_id, :date],
      name: :check_ins_user_id_habit_id_date_index,
      message: "hábito já registrado hoje"
    )
  end
end
