defmodule Radio.Mpd do
  use GenServer
  require Logger

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Server callbacks
  @impl true
  def init(_arg) do
    {:ok, start_server() |> IO.inspect(label: "p")}
  end

  @impl true
  def handle_info(msg, state) do
    IO.inspect(msg, label: "msg")
    {:noreply, state}
  end

  defp start_server() do
    target = Radio.Application.target()
    args = ["--no-daemon", Application.app_dir(:radio, "priv") <> "/mpd.#{target}.conf"]

    stream = IO.binstream(:standard_io, :line)
    Porcelain.spawn("/usr/bin/mpd", args, out: stream)
  end
end
