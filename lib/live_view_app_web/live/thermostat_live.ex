defmodule LiveViewAppWeb.ThermostatLive do
  use Phoenix.LiveView
  import Calendar.Strftime

  def render(assigns) do
    ~L"""
    <div class="thermostat">
      <div class="bar <%= @mode %>">
        <a href="#" phx-click="toggle-mode"><%= @mode %></a>
        <span><%= strftime!(@time, "%r") %></span>
      </div>
      <div class="controls">
        <span class="reading"><%= @val %></span>
        <button phx-click="dec" class="minus">-</button>
        <button phx-click="inc" class="plus">+</button>
        <span class="weather">
          <%= live_render(@socket, LiveViewAppWeb.WeatherLive, id: "weather") %>
        </span>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(100, self(), :tick)
    {:ok, assign(socket, val: 72, mode: :cooling, time: :calendar.local_time())}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, time: :calendar.local_time())}
  end

  def handle_event("inc", _, socket) do
    if socket.assigns.val >= 75, do: raise("boom")
    {:noreply, update(socket, :val, &(&1 + 1))}
  end

  def handle_event("dec", _, socket) do
    {:noreply, update(socket, :val, &(&1 - 1))}
  end

  def handle_event("toggle-mode", _, socket) do
    {:noreply,
     update(socket, :mode, fn
       :cooling -> :heating
       :heating -> :cooling
     end)}
  end
end
