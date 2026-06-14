defmodule EcoHabits.TrackingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EcoHabits.Tracking` context.
  """

  @doc """
  Generate a check_in.
  """
  def check_in_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        date: ~D[2026-06-13]
      })

    {:ok, check_in} = EcoHabits.Tracking.create_check_in(scope, attrs)
    check_in
  end
end
