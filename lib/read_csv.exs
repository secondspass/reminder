OptionParser.parse(System.argv())
|> elem(0)
|> Keyword.get(:path)
|> Reminder.API.insert_events_from_csv()
