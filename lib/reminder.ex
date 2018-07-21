defmodule Reminder do
  @moduledoc """
  Documentation for Reminder.
  """
  use Application

  def start(_type, _args) do
    Reminder.Supervisor.start_link(name: Reminder.Supervisor)
  end
end
