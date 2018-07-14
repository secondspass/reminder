defmodule Reminder do
  alias Reminder.Server
  alias Reminder.Events
  @moduledoc """
  Documentation for Reminder.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Reminder.hello
      :world

  """
  def hello do
    :world
  end

  def send_reminders do
    event_map = %{
      today: Server.get_today() |> Events.filter_events(:today),
      tomorrow: Server.get_tomorrow() |> Events.filter_events(:tomorrow),
      next_week: Server.get_next_week() |> Events.filter_events(:next_week),
      }

    event_map |> Events.create_message() |> Events.send_email()
  end
end
