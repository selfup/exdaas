defmodule ExDaas.Dets.Counter.Table do
  alias ExDaas.Cache.Model, as: Model
  use GenServer

  def start_link(opts \\ []) do
    [name: name, ets_table: ets_table] = opts

    GenServer.start_link(__MODULE__, [
      {:name, name},
      {:ets_table, ets_table},
    ], opts)
  end

  def init(args) do
    [{:name, name}, {:ets_table, ets_table}] = args
    
    {:ok, _} = :dets.open_file(name, [type: :set])

    case :dets.select(name, [{:"$1", [], [:"$1"]}]) do
      [] ->
        :dets.insert(name, {:counter, 1})
      payload ->
        Model.load_from_dets(payload, ets_table) 
    end

    {:ok, %{name: name, ets_table: ets_table}}
  end
end
