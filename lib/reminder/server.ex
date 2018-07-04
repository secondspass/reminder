defmodule Reminder.Server do
  use GenServer

  def init(_) do
    {:ok, file_db} =
      :dets.open_file(:reminders_dets, [{:file, Application.get_env(:reminder, :db)}])

    db = :ets.new(:reminders, [])
    :ets.from_dets(db, file_db)
    {:ok, db}
  end

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :rem_server)
  end

  def insert_event(date_erl, eventname, recurring, priority, desc) do
    GenServer.call(:rem_server, {:insert, date_erl, {eventname, recurring, priority, desc}})
  end

  def sync_to_dets do
    GenServer.cast(:rem_server, :sync)
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

  def handle_call({:insert, date, eventdetails}, _, db) do
    status =
      case :ets.lookup(db, date) do
        [] ->
          :ets.insert(db, {date, [eventdetails]}) && :inserted

        [{^date, eventlist}] ->
          if eventdetails not in eventlist do
            :ets.insert(db, {date, [eventdetails | eventlist]}) && :inserted
          else
            :event_already_present
          end
      end

    {:reply, status, db}
  end

  def handle_call({:get, day, month}, _, db) do
    event_data = :dets.match_object(db, {{:"$1", day, month}, :"$2"})
    {:reply, event_data, db}
  end

  def handle_cast(:sync, db) do
    :ets.to_dets(db, :reminders_dets)
    {:noreply, db}
  end
end
