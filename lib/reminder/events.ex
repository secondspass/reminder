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
    case Enum.filter(event_list,
	  fn
	    {_id, true, _priority, _desc} -> true
	    {_id, false, _priority, _desc} -> if Date.utc_today() == date, do: true, else: false
	  end
	) do
      [] -> {date, []}
      filtered_list -> {date, filtered_list}
    end
  end

  @doc """
  Formulates the message to be sent as email to user.
  """
  def create_message(event_map) do
    %Mailman.Email{
      subject: "Reminders for today",
      from: Application.get_env(:reminder, :from_email),
      to: [Application.get_env(:reminder, :to_email)],
      text: "hello",
    }
  end

  @doc """
  sends the message as email to the address (defined in config)
  """
  def send_email(email) do
    Reminder.Mailer.deliver(email)
  end
end

	    
