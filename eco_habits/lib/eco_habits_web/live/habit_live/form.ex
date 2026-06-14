defmodule EcoHabitsWeb.HabitLive.Form do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Habits
  alias EcoHabits.Habits.Habit

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage habit records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="habit-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:category]} type="text" label="Category" />
        <.input field={@form[:points]} type="number" label="Points" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Habit</.button>
          <.button navigate={return_path(@current_scope, @return_to, @habit)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    habit = Habits.get_habit!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Habit")
    |> assign(:habit, habit)
    |> assign(:form, to_form(Habits.change_habit(socket.assigns.current_scope, habit)))
  end

  defp apply_action(socket, :new, _params) do
    habit = %Habit{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Habit")
    |> assign(:habit, habit)
    |> assign(:form, to_form(Habits.change_habit(socket.assigns.current_scope, habit)))
  end

  @impl true
  def handle_event("validate", %{"habit" => habit_params}, socket) do
    changeset = Habits.change_habit(socket.assigns.current_scope, socket.assigns.habit, habit_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"habit" => habit_params}, socket) do
    save_habit(socket, socket.assigns.live_action, habit_params)
  end

  defp save_habit(socket, :edit, habit_params) do
    case Habits.update_habit(socket.assigns.current_scope, socket.assigns.habit, habit_params) do
      {:ok, habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, habit)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_habit(socket, :new, habit_params) do
    case Habits.create_habit(socket.assigns.current_scope, habit_params) do
      {:ok, habit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Habit created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, habit)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _habit), do: ~p"/habits"
  defp return_path(_scope, "show", habit), do: ~p"/habits/#{habit}"
end
