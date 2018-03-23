defmodule ExDaas.Dets.Table do
  alias ExDaas.Cache.Model, as: Model
  use GenServer

  def start_link(opts \\ []) do
    [name: name] = opts

    GenServer.start_link(__MODULE__, [
      {:dets_table_name, name},
      {:log_limit, 1_000_000},
    ], opts)
  end

  def terminate(_reason, _state) do
    IO.inspect :dets.close(:dets_table_one)
  end

  def init(args) do
    [{:dets_table_name, dets_table_name}, {:log_limit, log_limit}] = args
    
    {:ok, _} = :dets.open_file(dets_table_name, [type: :set])

    case :dets.select(dets_table_name, [{:"$1", [], [:"$1"]}]) do
      [] ->
        :dets.insert(dets_table_name, {:user_id_counter, 1})
      payload ->
        Model.load_from_dets(payload) 
    end

    {:ok, %{log_limit: log_limit, dets_table_name: dets_table_name}}
  end
end
