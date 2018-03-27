defmodule ExDaas.Ets.Table do
  alias ExDaas.Cache.Model, as: Model

  use GenServer

  def start_link(opts \\ []) do
    [name: name, dets_table: dets_table] = opts

    GenServer.start_link(__MODULE__, [
      {:name, name},
      {:dets_table, dets_table},
    ], opts)
  end

  def fetch(id, data, ets_table) do
    GenServer.call(ets_table, {:fetch, {id, data, ets_table}})
  end

  def handle_call({:fetch, {id, data, ets_table}}, _from, state) do
    %{dets_table: dets_table} = state
    {:reply, Model.fetch(id, data, ets_table, dets_table), state}
  end

  def init(args) do
    [
      {:name, name},
      {:dets_table, dets_table},
    ] = args
    
    :ets.new(name, [:named_table, :set, :public, read_concurrency: true])
    
    {:ok,
      %{
        name: name,
        dets_table: dets_table,
      },
    }
  end
end
