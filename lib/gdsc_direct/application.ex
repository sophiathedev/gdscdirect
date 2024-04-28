defmodule GdscDirect.Application do
  use Application

  @impl true
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    # put the application that disable the ansi color
    Application.put_env(:elixir, :ansi_enabled, false)

    children = [
      {Nosedrum.Storage.Dispatcher, name: Nosedrum.Storage.Dispatcher},
      GdscDirect.Consumer,
      GdscDirect.Scheduler.ResetDailyVisit
    ]

    opts = [strategy: :rest_for_one, name: GdscDirect.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
