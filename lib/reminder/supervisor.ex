defmodule Reminder.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, nil, opts)
  end

  def init(_) do
    children = [Reminder.Server, Reminder.Tasks.Sender, Reminder.Tasks.NotifyConnec]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
