defmodule Reminder.Server do
  use GenServer

  def init(_) do
    {:ok, file_db} = :dets.open_file(:reminders, [{:file, Application.get_env(:reminder, :db)}])
    db = :ets.from_dets(:ets.new(:reminders, []), file_db)
    {:ok, db}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :rem_server)
  end
  
  def insert_event do
    nil
  end

  @doc """
  Get today's events as [{{yyyy, mm, dd}, [eventlist]}, ...]
  """
  def get_today do
    date = Date.utc_today()
    GenServer.call(:rem_server, {:get, date.day, date.month})
  end
  
  def get_tomorrow do
    date = Date.add(Date.utc_today(), 1)
    GenServer.call(:rem_server, {:get, date.day, date.month})
  end

  def get_next_week do
    date = Date.add(Date.utc_today(), 7)
    GenServer.call(:rem_server, {:get, date.day, date.month})
  end

  def handle_call({:get, day, month}, _, db) do
    event_data = :dets.match_object(db, {{:"$1", day, month}, :"$2"})
    {:reply, event_data, db}
  end

end
