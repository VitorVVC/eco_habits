defmodule EcoHabitsWeb.CommunityFeedLive do
  use EcoHabitsWeb, :live_view

  alias EcoHabits.Tracking

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(EcoHabits.PubSub, "community:check_ins")
    end

    {:ok, assign(socket, :check_ins, Tracking.list_community_check_ins())}
  end

  def handle_info({:community_check_in, _check_in}, socket) do
    {:noreply, assign(socket, :check_ins, Tracking.list_community_check_ins())}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <section class="p-8 space-y-6">
        <h1 class="text-3xl font-bold">Feed da Comunidade</h1>
        <p>Check-ins mais recentes registrados pelos usuários.</p>

        <ul class="space-y-3">
          <%= for check_in <- @check_ins do %>
            <li class="border rounded p-4">
              Usuário ID <strong>{check_in.user_id}</strong>
              registrou o hábito ID <strong>{check_in.habit_id}</strong>
              em <strong>{check_in.date}</strong>.
            </li>
          <% end %>
        </ul>
      </section>
    </Layouts.app>
    """
  end
end
