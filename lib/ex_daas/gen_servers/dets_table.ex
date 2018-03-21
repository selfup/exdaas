defmodule ExDaas.Dets.Table do
  alias ExDaas.Cache.Model, as: Model
  use GenServer

  @moduledoc """
  Use GenServer to recreate table in Supervision tree in case of failure
  """

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [
      {:dets_table_name, :user_table},
      {:log_limit, 1_000_000},
    ], opts)
  end

  def fetch(id, data) do
    GenServer.call(__MODULE__, {:fetch, {id, data}})
  end

  def handle_call({:fetch, {id, data}}, _from, state) do
    {:reply, Model.fetch(id, data), state}
  end

  def terminate(_reason, _state) do
    IO.inspect :dets.close(:exdaas_persistance_table)
  end

  def init(args) do
    [{:dets_table_name, dets_table_name}, {:log_limit, log_limit}] = args
    
    {:ok, _} = :dets.open_file(:exdaas_persistance_table, [type: :set])

    case :dets.select(:exdaas_persistance_table, [{:"$1", [], [:"$1"]}]) do
      [] ->
        :dets.insert(:exdaas_persistance_table, {:user_id_counter, 1})
      payload ->
        Model.load_from_dets(payload) 
    end

    {:ok, %{log_limit: log_limit, dets_table_name: dets_table_name}}
  end
end
