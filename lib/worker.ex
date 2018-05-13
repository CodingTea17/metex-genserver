defmodule MetexGenserver.Worker do
  use GenServer

  # Client

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_temp(pid, location) do
    GenServer.call(pid, {:location, location})
  end

  # Server

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:location, location}, _from, stats) do
    case temp_of(location) do
      {:ok, temp} ->
        new_stats = update_stats(stats, location)
        {:reply, "#{temp}°C", new_stats}

      _ ->
        {:reply, :error, stats}
    end
  end

  # Helper

  defp temp_of(location) do
    url_for(location) |> HTTPoison.get() |> parse_res()
  end

  defp url_for(location) do
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&APPID=#{apikey}"
  end

  defp parse_res({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temp
  end

  defp parse_res(_) do
    :error
  end

  defp compute_temp(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp apikey do
    System.get_env("WEATHER_API_KEY")
  end

  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true ->
        Map.update!(old_stats, location, &(&1 + 1))
      false ->
        Map.put_new(old_stats, location, 1)
    end
  end
end
