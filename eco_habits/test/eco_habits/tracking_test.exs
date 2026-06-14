defmodule EcoHabits.TrackingTest do
  use EcoHabits.DataCase

  alias EcoHabits.Tracking

  describe "check_ins" do
    alias EcoHabits.Tracking.CheckIn

    import EcoHabits.AccountsFixtures, only: [user_scope_fixture: 0]
    import EcoHabits.TrackingFixtures

    @invalid_attrs %{date: nil}

    test "list_check_ins/1 returns all scoped check_ins" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      check_in = check_in_fixture(scope)
      other_check_in = check_in_fixture(other_scope)
      assert Tracking.list_check_ins(scope) == [check_in]
      assert Tracking.list_check_ins(other_scope) == [other_check_in]
    end

    test "get_check_in!/2 returns the check_in with given id" do
      scope = user_scope_fixture()
      check_in = check_in_fixture(scope)
      other_scope = user_scope_fixture()
      assert Tracking.get_check_in!(scope, check_in.id) == check_in
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_check_in!(other_scope, check_in.id) end
    end

    test "create_check_in/2 with valid data creates a check_in" do
      valid_attrs = %{date: ~D[2026-06-13]}
      scope = user_scope_fixture()

      assert {:ok, %CheckIn{} = check_in} = Tracking.create_check_in(scope, valid_attrs)
      assert check_in.date == ~D[2026-06-13]
      assert check_in.user_id == scope.user.id
    end

    test "create_check_in/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracking.create_check_in(scope, @invalid_attrs)
    end

    test "update_check_in/3 with valid data updates the check_in" do
      scope = user_scope_fixture()
      check_in = check_in_fixture(scope)
      update_attrs = %{date: ~D[2026-06-14]}

      assert {:ok, %CheckIn{} = check_in} = Tracking.update_check_in(scope, check_in, update_attrs)
      assert check_in.date == ~D[2026-06-14]
    end

    test "update_check_in/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      check_in = check_in_fixture(scope)

      assert_raise MatchError, fn ->
        Tracking.update_check_in(other_scope, check_in, %{})
      end
    end

    test "update_check_in/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      check_in = check_in_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Tracking.update_check_in(scope, check_in, @invalid_attrs)
      assert check_in == Tracking.get_check_in!(scope, check_in.id)
    end

    test "delete_check_in/2 deletes the check_in" do
      scope = user_scope_fixture()
      check_in = check_in_fixture(scope)
      assert {:ok, %CheckIn{}} = Tracking.delete_check_in(scope, check_in)
      assert_raise Ecto.NoResultsError, fn -> Tracking.get_check_in!(scope, check_in.id) end
    end

    test "delete_check_in/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      check_in = check_in_fixture(scope)
      assert_raise MatchError, fn -> Tracking.delete_check_in(other_scope, check_in) end
    end

    test "change_check_in/2 returns a check_in changeset" do
      scope = user_scope_fixture()
      check_in = check_in_fixture(scope)
      assert %Ecto.Changeset{} = Tracking.change_check_in(scope, check_in)
    end
  end
end
