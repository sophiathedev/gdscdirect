defmodule GdscDirect.Scheduler.ResetDailyVisit do
  use GenServer
  require Logger

  alias GdscDirect.Database

  def start_link(state) do
    GenServer.start(__MODULE__, state)
  end

  @impl true
  @spec init(any()) :: {:ok, any()}
  def init(state) do
    Process.send_after(self(), :worker, ms_til_utc_midnight())
    Logger.info("Started initialize task reset daily visit")
    {:ok, state}
  end

  @doc "This function will calculate time in millisecond til midnight is 12:00 in utc time it 07:00 at UTC+07"
  @spec ms_til_utc_midnight() :: integer()
  def ms_til_utc_midnight do
    now = DateTime.utc_now()
    unix_now_ms = DateTime.to_unix(now, :millisecond)

    # get next midnight by adding one day into current utc time
    tommorow = now |> DateTime.add(1, :day) |> DateTime.to_date()
    tommorow_midnight = DateTime.new!(tommorow, Time.new!(0, 0, 0))
    tommorow_midnight_unix_ms = tommorow_midnight |> DateTime.to_unix(:millisecond)
    tommorow_midnight_unix_ms - unix_now_ms
  end

  @impl true
  def handle_info(:worker, state) do
    # do the work
    process_start()

    # ms in day 86_400_000
    Process.send_after(self(), :worker, 86_400_000)
    {:noreply, state}
  end

  def process_start() do
    Logger.info("WORKER reset_daily_visit started at time")

    # reset visit in a day
    Database.update(:user, [:visited], [0])

    # if user have streak greater or equal 14, add 10 credits into user
    Database.update(:user, [:credits], ["credits + 10"], "where visit_streak >= 14")

    {:ok}
  end
end
