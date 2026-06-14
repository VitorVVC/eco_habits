defmodule EcoHabitsWeb.DashboardLive do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits
  alias EcoHabits.Tracking

  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    if connected?(socket) do
      Tracking.subscribe_check_ins(scope)
    end

    habits = Habits.list_habits(scope)
    check_ins = Tracking.list_recent_check_ins(scope)
    total_points = calculate_points(habits, check_ins)

    socket =
      socket
      |> assign(:habits, habits)
      |> assign(:check_ins, check_ins)
      |> assign(:total_points, total_points)

    {:ok, socket}
  end

  def handle_event("check_in", %{"habit_id" => habit_id}, socket) do
    scope = socket.assigns.current_scope

    case Tracking.check_in_today(scope, String.to_integer(habit_id)) do
      {:ok, _check_in} ->
        habits = Habits.list_habits(scope)
        check_ins = Tracking.list_recent_check_ins(scope)

        socket =
          socket
          |> put_flash(:info, "Check-in registrado com sucesso!")
          |> assign(:habits, habits)
          |> assign(:check_ins, check_ins)
          |> assign(:total_points, calculate_points(habits, check_ins))

        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Esse hábito já foi registrado hoje.")}
    end
  end

  def handle_info({:created, _check_in}, socket) do
    scope = socket.assigns.current_scope

    habits = Habits.list_habits(scope)
    check_ins = Tracking.list_recent_check_ins(scope)

    socket =
      socket
      |> assign(:habits, habits)
      |> assign(:check_ins, check_ins)
      |> assign(:total_points, calculate_points(habits, check_ins))

    {:noreply, socket}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <main class="p-8 space-y-8">
      <section>
        <h1 class="text-3xl font-bold">EcoHabits - Dashboard</h1>
        <p class="mt-2">Pontuação acumulada: <strong>{@total_points}</strong></p>
      </section>

      <section>
        <h2 class="text-2xl font-semibold">Hábitos disponíveis</h2>

        <div class="mt-4 space-y-4">
          <%= for habit <- @habits do %>
            <div class="border rounded p-4">
              <h3 class="font-bold">{habit.name}</h3>
              <p>{habit.description}</p>
              <p>Categoria: {habit.category}</p>
              <p>Pontos: {habit.points}</p>

              <button
                phx-click="check_in"
                phx-value-habit_id={habit.id}
                class="mt-2 px-4 py-2 border rounded"
              >
                Registrar check-in de hoje
              </button>
            </div>
          <% end %>
        </div>
      </section>

      <section>
        <h2 class="text-2xl font-semibold">Check-ins recentes</h2>

        <ul class="mt-4 space-y-2">
          <%= for check_in <- @check_ins do %>
            <li>
              Hábito ID {check_in.habit_id} registrado em {check_in.date}
            </li>
          <% end %>
        </ul>
      </section>
    </main>
    """
  end

  defp calculate_points(habits, check_ins) do
    Enum.reduce(check_ins, 0, fn check_in, acc ->
      habit = Enum.find(habits, fn h -> h.id == check_in.habit_id end)

      if habit do
        acc + habit.points
      else
        acc
      end
    end)
  end
end
