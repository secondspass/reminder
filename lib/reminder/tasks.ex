defmodule Reminder.Tasks.Sender do
  @moduledoc """
  Sends the email at the time specified in the config everyday.
  """
  use Task, restart: :permanent
  @ms_24hrs 86_400_000

  def start_link(_opts) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    send_time = Application.get_env(:reminder, :time, ~T[12:00:00])

    cond do
      Time.utc_now() == send_time ->
        Reminder.API.send_reminder()
        Process.sleep(@ms_24hrs - 10000)

      Time.utc_now() < send_time ->
        IO.puts("current time is less than set time")
        Time.diff(send_time, Time.utc_now(), :milliseconds) |> Process.sleep()
        Reminder.API.send_reminder()

      Time.utc_now() > send_time ->
        IO.puts("current time is greater than set time")
        Process.sleep(@ms_24hrs - Time.diff(Time.utc_now(), send_time))
        Reminder.API.send_reminder()
    end

    run()
  end
end

defmodule Reminder.Tasks.Eraser do
  @moduledoc """
  task to remove obsolete events from db. runs once a month.
  """
  use Task, restart: :permanent
end