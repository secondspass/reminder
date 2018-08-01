#! /usr/local/bin/elixir

defmodule RemApp do
  def start_app do
    case Node.connect(:reminder_server@localhost) do
      true ->
        IO.puts("App is already started") && :ready

      false ->
        spawn(fn ->
          System.cmd(
            "nohup",
            ["elixir", "--sname", "reminder_server@localhost", "-S", "mix", "run", "--no-halt"],
            env: [{"MIX_ENV", "prod"}]
          )
        end)

        receive do
          :ready -> IO.puts("started the server") && :ready
        after
          10000 -> IO.puts("The server is taking too long to start") && :quit
        end

      reply ->
        raise "Some thing went wrong: #{reply}"
    end
  end

  def insert_csv(path) do
    case RemApp.start_app() do
      :ready ->
        Node.spawn(:reminder_server@localhost, Reminder.API, :insert_events_from_csv, [path])
        IO.puts("inserted events")

      :quit ->
        IO.puts("Exiting script")
    end
  end

  def reset_server do
    case RemApp.start_app() do
      :ready ->
        Node.spawn(:reminder_server@localhost, Reminder.Server, :delete_all_events, [])
        IO.puts("resetted server")

      :quit ->
        IO.puts("Exiting script")
    end
  end
end

Node.start(:connec@localhost, :shortnames)
Process.register(self(), :connec_script)

case OptionParser.parse(System.argv(), strict: [csv: :string, reset: :boolean]) |> elem(0) do
  [] -> RemApp.start_app()
  [csv: path] -> RemApp.insert_csv(path)
  [reset: true] -> RemApp.reset_server()
  _ -> raise "Invalid option"
end

Node.spawn(:reminder_server@localhost, Reminder.Server, :sync_to_dets, [])

