defmodule Radio.Buttons do
  use GenServer
  require Logger

  @vendor 4292
  @rpi_port "ttyAMA0"

  defstruct pid: nil, volume: 0, power: 0, a: 0, b: 0, c: 0, d: 0
  alias __MODULE__, as: State

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Server callbacks
  @impl true
  def init(_arg) do
    port_info =
      Circuits.UART.enumerate()
      |> Enum.find(fn {k, v} -> k == @rpi_port || v[:vendor_id] == @vendor end)

    with {port, _info} <- port_info,
         {:ok, pid} <- Circuits.UART.start_link(),
         :ok <- Circuits.UART.open(pid, port, speed: 9600, active: true) do
      Circuits.UART.configure(pid, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})

      {:ok, %State{pid: pid}}
    else
      _ ->
        Logger.warn("Failed opening buttons controller")

        :ignore
    end
  end

  @impl true
  def handle_info({:circuits_uart, _, line}, state) do
    case String.split(line, " ") do
      [volume, "x", d, c, b, a, power] ->
        [volume, d, c, b, a, power] =
          [volume, d, c, b, a, power] |> Enum.map(&String.to_integer/1)

        IO.inspect(volume, label: "volume")

        volume = handle_volume_change(state.volume, volume)
        handle_next(state.a, a)

        state = %State{state | volume: volume, a: a}
        {:noreply, state}

      _ ->
        IO.inspect(line, label: "?")
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(message, state) do
    IO.inspect(message, label: "message")

    {:noreply, state}
  end

  defp handle_volume_change(x, x), do: x

  defp handle_volume_change(old, new) do
    if abs(old - new) > 4 do
      vol = trunc(100 * new / 1024.0)
      IO.inspect(vol, label: "vol")
      Logger.info("Set volume: #{vol}")

      Paracusia.MpdClient.Playback.set_volume(vol)
      new
    else
      old
    end
  end

  defp handle_next(x, x), do: :ok

  defp handle_next(1, 0) do
    Logger.info("next!")
    Paracusia.MpdClient.Playback.next()
  end

  defp handle_next(_, _), do: :nop
end
