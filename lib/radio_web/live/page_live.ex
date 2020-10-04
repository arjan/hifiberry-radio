defmodule RadioWeb.PageLive do
  use RadioWeb, :live_view

  defp defaults(socket) do
    socket
    |> assign(:current_song, %{})
    |> assign(:status, %Paracusia.PlayerState.Status{})
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = defaults(socket)

    if connected?(socket) do
      :timer.send_interval(1000, :poll)
      Paracusia.PlayerState.subscribe(self())
    end

    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  @impl true
  def handle_info(:poll, socket) do
    {:ok, status} = Paracusia.MpdClient.Status.status()
    {:ok, current_song} = Paracusia.MpdClient.Status.current_song()

    socket =
      socket
      |> assign(:current_song, current_song)
      |> assign(:status, status)

    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "msg")

    {:noreply, socket}
  end

  defp search(query) do
    if not RadioWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
