defmodule Reminder.Server do
  use GenServer

  def init(state) do
    {:ok, state, 3000}
  end

  def handle_info(:timeout, state) do
    IO.puts("timing out")
    {:noreply, state}
  end
end
