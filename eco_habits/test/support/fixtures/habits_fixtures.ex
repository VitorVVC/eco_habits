defmodule EcoHabits.HabitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EcoHabits.Habits` context.
  """

  @doc """
  Generate a habit.
  """
  def habit_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        category: "some category",
        description: "some description",
        name: "some name",
        points: 42
      })

    {:ok, habit} = EcoHabits.Habits.create_habit(scope, attrs)
    habit
  end
end
