defmodule ExDaas.Ets.Counter.Table do
  alias ExDaas.Cache.Model, as: Model

  use GenServer

  def start_link(opts \\ []) do
    [name: name] = opts

    GenServer.start_link(__MODULE__, [
      {:name, name},
    ], opts)
  end

  def new_id(ets_table) do
    GenServer.call(ets_table, {:new_id, {}})
  end

  def handle_call({:new_id, {}}, _from, state) do
    {:reply, Model.new_id(), state}
  end

  def init(args) do
    [{:name, name}] = args
    
    :ets.new(name,
      [:named_table, :set, :public, read_concurrency: true]
    )
    
    {:ok, %{name: name}}
  end
end
