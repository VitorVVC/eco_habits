defmodule EcoHabitsWeb.HabitLive.Index do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits

  @categories ["alimentação", "transporte", "energia", "água", "resíduos"]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Habits
        <:actions>
          <.button variant="primary" navigate={~p"/habits/new"}>
            <.icon name="hero-plus" /> New Habit
          </.button>
        </:actions>
      </.header>

      <form phx-change="filter" class="mb-4">
        <label>Filtrar por categoria:</label>

        <select name="category" class="border rounded p-2">
          <option value="">Todas</option>
          <%= for category <- @categories do %>
            <option value={category} selected={@selected_category == category}>
              {category}
            </option>
          <% end %>
        </select>
      </form>

      <.table
        id="habits"
        rows={@streams.habits}
        row_click={fn {_id, habit} -> JS.navigate(~p"/habits/#{habit}") end}
      >
        <:col :let={{_id, habit}} label="Name">{habit.name}</:col>
        <:col :let={{_id, habit}} label="Description">{habit.description}</:col>
        <:col :let={{_id, habit}} label="Category">{habit.category}</:col>
        <:col :let={{_id, habit}} label="Points">{habit.points}</:col>

        <:action :let={{_id, habit}}>
          <div class="sr-only">
            <.link navigate={~p"/habits/#{habit}"}>Show</.link>
          </div>
          <.link navigate={~p"/habits/#{habit}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, habit}}>
          <.link
            phx-click={JS.push("delete", value: %{id: habit.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Habits.subscribe_habits(socket.assigns.current_scope)
    end

    habits = list_habits(socket.assigns.current_scope, "")

    {:ok,
     socket
     |> assign(:page_title, "Listing Habits")
     |> assign(:categories, @categories)
     |> assign(:selected_category, "")
     |> stream(:habits, habits)}
  end

  @impl true
  def handle_event("filter", %{"category" => category}, socket) do
    habits = list_habits(socket.assigns.current_scope, category)

    {:noreply,
     socket
     |> assign(:selected_category, category)
     |> stream(:habits, habits, reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    habit = Habits.get_habit!(socket.assigns.current_scope, id)
    {:ok, _} = Habits.delete_habit(socket.assigns.current_scope, habit)

    {:noreply, stream_delete(socket, :habits, habit)}
  end

  @impl true
  def handle_info({type, %EcoHabits.Habits.Habit{}}, socket)
      when type in [:created, :updated, :deleted] do
    habits = list_habits(socket.assigns.current_scope, socket.assigns.selected_category)

    {:noreply, stream(socket, :habits, habits, reset: true)}
  end

  defp list_habits(current_scope, ""), do: Habits.list_habits(current_scope)

  defp list_habits(current_scope, category) do
    current_scope
    |> Habits.list_habits()
    |> Enum.filter(fn habit -> habit.category == category end)
  end
end
