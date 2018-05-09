defmodule MetexGenserver.Worker do
  use GenServer

  # Client
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  #Server
  def init(:ok) do
    {:ok, %{}}
  end

end
