defmodule EcoHabits.Repo.Migrations.CreateCheckIns do
  use Ecto.Migration

  def change do
    create table(:check_ins) do
      add :date, :date
      add :habit_id, references(:habits, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:check_ins, [:user_id])

    create index(:check_ins, [:habit_id])
  end
end
