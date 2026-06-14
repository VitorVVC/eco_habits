defmodule EcoHabitsWeb.HabitLive.Show do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Habit {@habit.id}
        <:subtitle>This is a habit record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/habits"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/habits/#{@habit}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit habit
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@habit.name}</:item>
        <:item title="Description">{@habit.description}</:item>
        <:item title="Category">{@habit.category}</:item>
        <:item title="Points">{@habit.points}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Habits.subscribe_habits(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Habit")
     |> assign(:habit, Habits.get_habit!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %EcoHabits.Habits.Habit{id: id} = habit},
        %{assigns: %{habit: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :habit, habit)}
  end

  def handle_info(
        {:deleted, %EcoHabits.Habits.Habit{id: id}},
        %{assigns: %{habit: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current habit was deleted.")
     |> push_navigate(to: ~p"/habits")}
  end

  def handle_info({type, %EcoHabits.Habits.Habit{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
