defmodule EcoHabitsWeb.ProfileLive do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Accounts
  alias EcoHabits.Habits
  alias EcoHabits.Tracking

  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    user = scope.user
    habits = Habits.list_habits(scope)
    check_ins = Tracking.list_check_ins(scope)

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:form, to_form(Accounts.User.profile_changeset(user, %{})))
     |> assign(:total_points, calculate_points(habits, check_ins))}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_profile(socket.assigns.user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:user, user)
         |> assign(:form, to_form(Accounts.User.profile_changeset(user, %{})))
         |> put_flash(:info, "Perfil atualizado com sucesso!")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <section class="p-8 space-y-6">
        <h1 class="text-3xl font-bold">Meu Perfil</h1>

        <p><strong>Email:</strong> {@user.email}</p>
        <p><strong>Pontuação total:</strong> {@total_points}</p>

        <.form for={@form} phx-submit="save" class="space-y-4">
          <.input field={@form[:name]} label="Nome" />
          <.input field={@form[:bio]} label="Bio" type="textarea" />

          <.button>Salvar perfil</.button>
        </.form>
      </section>
    </Layouts.app>
    """
  end

  defp calculate_points(habits, check_ins) do
    Enum.reduce(check_ins, 0, fn check_in, acc ->
      habit = Enum.find(habits, fn h -> h.id == check_in.habit_id end)

      if habit, do: acc + habit.points, else: acc
    end)
  end
end
