defmodule ExDaas.Ets.Counter.Table do
  use GenServer

  def start_link(opts \\ []) do
    [name: name] = opts

    GenServer.start_link(
      __MODULE__,
      [
        {:name, name}
      ],
      opts
    )
  end

  def init(args) do
    [{:name, name}] = args

    :ets.new(name, [:named_table, :set, :public, read_concurrency: true])

    {:ok, %{name: name}}
  end
end
