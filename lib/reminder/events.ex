defmodule Reminder.Events do
  # def send_events_reminder(event_data) do
  #   case filter_events(event_data) do
  #     :no_events -> quit
  #     list_of_events -> list_of_events |> create_msg() |> send_email()
  #   end
  # end

  @doc """
  Takes the data retrieved from the ets table (which will be in a form something like so):

  iex> today = Date.utc_today()
  iex> Reminder.Events.filter_events([
  ...>        # dates are in erlang format
  ...>        {Date.to_erl(today),
  ...>         [
  ...>           {"Event1", false, 1, "Is an event"},
  ...>           {"Event2", true, 1, "Is also an event"},
  ...>           {"Event3", false, 2, "Is another event"},
  ...>           {"Event4", true, 2, "Is yet another event"}
  ...>         ]},
  ...>        # same day and month as today but past year
  ...>        {{2012, today.month, today.day},
  ...>         [
  ...>           {"Event5", false, 1, "Is an event"},
  ...>           {"Event6", true, 1, "Is also an event"},
  ...>           {"Event7", false, 2, "Is another event"},
  ...>           {"Event8", true, 2, "Is yet another event"}
  ...>         ]},
  ...>        # same day and month as today but future year
  ...>        {{2100, today.month, today.day},
  ...>         [
  ...>           {"Event9", false, 1, "Is an event"},
  ...>           {"Event10", true, 1, "Is also an event"},
  ...>           {"Event11", false, 2, "Is another event"},
  ...>           {"Event12", true, 2, "Is yet another event"}
  ...>         ]}
  ...> ])
  [{"Event1", false, 1, "Is an event"}, {"Event2", true, 1, "Is also an event"}, {"Event3", false, 2, "Is another event"}, {"Event4", true, 2, "Is yet another event"}, {"Event6", true, 1, "Is also an event"}, {"Event8", true, 2, "Is yet another event"}]

  and produce the the event list alone after filtering out the unwanted events.

  ## The rules for filtering out events are as follows
  ### If key is :today
  Referring to today's events (i.e. corresponding to today's day and month, year can be different) then
  * if it is a past year, filter out only the non recurring events
  * if it is the current year, don't filter out any event
  * if it is a future year, filter out all the events

  ### If key is :tomorrow
  Referring to tomorrow's events (i.e. corresponding to tomorrow's day and month, year can be different) then
  * if it is a past year, filter out only the non recurring events
  * if it is the current year, don't filter out any event
  * if it is a future year, filter out all the events

  ### If key is :next week
  Referring to next week's events (i.e. corresponding to next week's day and month, year can be different) then
  * if it is a past year, filter out non recurring and low priority events
  * if it is the current year, don't filter out only the low priority events event
  * if it is a future year, filter out all the events
  """
  def filter_events(date_event_list_tuple_list, key)
      when key in [:today, :tomorrow, :next_week] do
    final_list = Enum.flat_map(date_event_list_tuple_list, fn x -> filter_pipeline(x, key) end)

    case final_list do
      [] -> :no_events
      _ -> final_list
    end
  end

  @doc """
  filtering events for both today and tomorrow produce the same output. because all of this years priority 1 and priority 2 events
  must be displayed, old non recurring events must be removed, and future year events must not be shown.
  """
  def filter_pipeline({{year, _month, _day}, event_list}, :today)
      when is_list(event_list) do
    date = Date.utc_today()

    cond do
      year > date.year -> []
      year < date.year -> event_list |> filter_non_recurring_events()
      year == date.year -> event_list
    end
  end

  def filter_pipeline({{year, _month, _day}, event_list}, :tomorrow)
      when is_list(event_list) do
    date = Date.add(Date.utc_today(), 1)

    cond do
      year > date.year -> []
      year < date.year -> event_list |> filter_non_recurring_events()
      year == date.year -> event_list
    end
  end

  def filter_pipeline({{year, _month, _day}, event_list}, :next_week)
      when is_list(event_list) do
    date = Date.add(Date.utc_today(), 7)

    cond do
      year > date.year ->
        []

      year < date.year ->
        event_list |> filter_non_recurring_events() |> filter_low_priority_events()

      year == date.year ->
        event_list |> filter_low_priority_events()
    end
  end

  @doc """
  Filters out events that are non recurring if the date is today.
  Notifies if event list is empty after filtering. Each event is
  of the form {event name, recurring (true/false), priority (1,2), description}.
  """
  def filter_non_recurring_events(event_list) do
    Enum.filter(event_list, fn
      {_id, true, _priority, _desc} -> true
      {_id, false, _priority, _desc} -> false
    end)
  end

  @doc """
  Filter out events that are low priority (i.e. priority 1). Used only with the next_week events.
  """
  def filter_low_priority_events(event_list) do
    Enum.filter(event_list, fn
      {_id, _recur, 1, _desc} -> false
      _ -> true
    end)
  end

  @doc """
  Formulates the message to be sent as email to user.
  """
  def create_message(event_map) do
    %Mailman.Email{
      subject: "Reminders for today",
      from: Application.get_env(:reminder, :from_email),
      to: [Application.get_env(:reminder, :to_email)],
      data: [event_map: event_map],
      text: """
      Events for today (#{Date.utc_today()}):

      <%= Enum.map(event_map.today, fn item -> elem(item, 0) <> " - " <> elem(item, 3) <> "\n" end) %>
      Events for tomorrow (#{Date.add(Date.utc_today(), 1)}):

      <%= Enum.map(event_map.tomorrow, fn item -> elem(item, 0) <> " - " <> elem(item, 3) <> "\n" end) %>
      Events for next week (#{Date.add(Date.utc_today(), 7)}):

      <%= Enum.map(event_map.next_week, fn item -> elem(item, 0) <> " - " <> elem(item, 3) <> "\n" end) %>
      """
    }
  end

  @doc """
  sends the message as email to the receiver address (defined in config files)
  """
  def send_email(email) do
    Reminder.Mailer.deliver(email)
  end
end
