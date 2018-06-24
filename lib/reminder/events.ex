# REMINDERS:
# set priorities for the events
defmodule Reminder.Events do
  # def send_events_reminder(event_data) do
  #   case filter_events(event_data) do
  #     :no_events -> quit
  #     list_of_events -> list_of_events |> create_msg() |> send_email()
  #   end
  # end

  @doc """
  Filters out events that are non recurring if the date is today.
  Notifies if event list is empty after filtering. Each event is
  of the form {event name, recurring (true/false), priority (1,2), description}.
  """
  def filter_non_recurring_events({date, event_list}) do
    {date,
     Enum.filter(event_list, fn
       {_id, true, _priority, _desc} -> true
       {_id, false, _priority, _desc} -> if date >= Date.utc_today(), do: true, else: false
     end)}
  end

  @doc """
  Filter out events that are low priority (i.e. priority 1). Used only with the next_week events.
  """
  def filter_low_priority_events({date, event_list}) do
    {date,
     Enum.filter(event_list, fn
       {_id, _recur, 1, _desc} -> false
       _ -> true
     end)}
  end

  @doc """
  Identifies if the event list is empty. Returns :no_event if empty, otherwise returns
  {date, event_list}.
  """
  def filter_empty({date, event_list}) when event_list == [] do
    :no_events
  end
  def filter_empty({date, event_list}), do: {date, event_list}

  @doc """
  Formulates the message to be sent as email to user.
  """
  def create_message(event_map) do
    %Mailman.Email{
      subject: "Reminders for today",
      from: Application.get_env(:reminder, :from_email),
      to: [Application.get_env(:reminder, :to_email)],
      text: "hello"
    }
  end

  @doc """
  sends the message as email to the address (defined in config)
  """
  def send_email(email) do
    Reminder.Mailer.deliver(email)
  end
end

