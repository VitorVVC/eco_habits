defmodule EcoHabits.Repo.Migrations.AddUniqueIndexToCheckIns do
  use Ecto.Migration

  def change do
    create unique_index(:check_ins, [:user_id, :habit_id, :date],
             name: :check_ins_user_id_habit_id_date_index
           )
  end
end
