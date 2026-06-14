defmodule EcoHabits.HabitsTest do
  use EcoHabits.DataCase

  alias EcoHabits.Habits

  describe "habits" do
    alias EcoHabits.Habits.Habit

    import EcoHabits.AccountsFixtures, only: [user_scope_fixture: 0]
    import EcoHabits.HabitsFixtures

    @invalid_attrs %{name: nil, description: nil, category: nil, points: nil}

    test "list_habits/1 returns all scoped habits" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      habit = habit_fixture(scope)
      other_habit = habit_fixture(other_scope)
      assert Habits.list_habits(scope) == [habit]
      assert Habits.list_habits(other_scope) == [other_habit]
    end

    test "get_habit!/2 returns the habit with given id" do
      scope = user_scope_fixture()
      habit = habit_fixture(scope)
      other_scope = user_scope_fixture()
      assert Habits.get_habit!(scope, habit.id) == habit
      assert_raise Ecto.NoResultsError, fn -> Habits.get_habit!(other_scope, habit.id) end
    end

    test "create_habit/2 with valid data creates a habit" do
      valid_attrs = %{name: "some name", description: "some description", category: "some category", points: 42}
      scope = user_scope_fixture()

      assert {:ok, %Habit{} = habit} = Habits.create_habit(scope, valid_attrs)
      assert habit.name == "some name"
      assert habit.description == "some description"
      assert habit.category == "some category"
      assert habit.points == 42
      assert habit.user_id == scope.user.id
    end

    test "create_habit/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Habits.create_habit(scope, @invalid_attrs)
    end

    test "update_habit/3 with valid data updates the habit" do
      scope = user_scope_fixture()
      habit = habit_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description", category: "some updated category", points: 43}

      assert {:ok, %Habit{} = habit} = Habits.update_habit(scope, habit, update_attrs)
      assert habit.name == "some updated name"
      assert habit.description == "some updated description"
      assert habit.category == "some updated category"
      assert habit.points == 43
    end

    test "update_habit/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      habit = habit_fixture(scope)

      assert_raise MatchError, fn ->
        Habits.update_habit(other_scope, habit, %{})
      end
    end

    test "update_habit/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      habit = habit_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Habits.update_habit(scope, habit, @invalid_attrs)
      assert habit == Habits.get_habit!(scope, habit.id)
    end

    test "delete_habit/2 deletes the habit" do
      scope = user_scope_fixture()
      habit = habit_fixture(scope)
      assert {:ok, %Habit{}} = Habits.delete_habit(scope, habit)
      assert_raise Ecto.NoResultsError, fn -> Habits.get_habit!(scope, habit.id) end
    end

    test "delete_habit/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      habit = habit_fixture(scope)
      assert_raise MatchError, fn -> Habits.delete_habit(other_scope, habit) end
    end

    test "change_habit/2 returns a habit changeset" do
      scope = user_scope_fixture()
      habit = habit_fixture(scope)
      assert %Ecto.Changeset{} = Habits.change_habit(scope, habit)
    end
  end
end
