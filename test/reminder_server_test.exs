defmodule ReminderServerTest do
  use ExUnit.Case
  doctest Reminder
  alias Reminder.Server

  def init(_) do
    # NOTES: remember to change it to reflect test and prod envs
    {:ok, db} = :dets.open_file(:reminders, [{:file, 'priv/rems.db'}])
    {:ok, db}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end
  
  def insert_event do
    nil
  end

  @doc """
  Get today's events as [{{yyyy, mm, dd}, [eventlist]}, ...]
  """
  def get_today do
    date = Date.utc_today()
    
  end

  def get_tomorrow do
  end

  def get_next_week do
  end

  def handle_call({:get, day, month}, _, db) do
    :dets.match_object(db, {{:"$1", day, month}, :"$2"})
  end

end


  
    
    
  # need to create prod and test ets tables
  # decide on the data structure to hold the today, tomorrow and next week events (just use a list)
end
