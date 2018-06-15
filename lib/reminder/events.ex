# also see if date sigils can be read and written in ets and dets tables
defmodule Reminder.Events do

  # def send_events_reminder(event_data) do
  #   case filter_events(event_data) do
  #     :no_events -> quit
  #     list_of_events -> list_of_events |> create_msg() |> send_email()
  #   end
  # end

  @doc """
  Filters out events that are non recurring if the date is today.
  Notifies if event list is empty after filtering
  """
  def filter_events({_date, []}) do
    :no_events
  end
  def filter_events({date, event_list}) do
    case Enum.filter(event_list,
	  fn
	    {_id, true, _desc} -> true
	    {_id, false, _desc} -> if Date.utc_today() == date, do: true, else: false
	  end
	) do
      [] -> :no_events
      filtered_list -> filtered_list
    end
  end

  @doc """
  Formulates the message to be sent as email to user.
  """
  def create_message(event_list) do
    event_to_msg = fn {event, _recur, desc} -> "#{event} - #{desc}" end
    """
    Events for today (#{Date.utc_today()}):

    #{event_list |> Enum.map(event_to_msg) |> Enum.join("\n")}
    """
  end

  @doc """
  sends the message as email to the address (defined in config)
  """
  def send_email(message) do
    nil
  end
  
end

	    
