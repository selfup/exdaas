defmodule ExDaas.Ets.Table do
  alias ExDaas.Cache.Model, as: Model

  use GenServer

  @moduledoc """
  Use GenServer to recreate table in Supervision tree in case of failure
  """

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [
      {:ets_table_name, :exdaas_cache_table},
      {:log_limit, 1_000_000},
    ], opts)
  end

  def fetch(id, data) do
    GenServer.call(__MODULE__, {:fetch, {id, data}})
  end

  def handle_call({:fetch, {id, data}}, _from, state) do
    {:reply, Model.fetch(id, data), state}
  end

  def init(args) do
    [{:ets_table_name, ets_table_name}, {:log_limit, log_limit}] = args
    
    :ets.new(ets_table_name, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
    ])
    
    {:ok, %{log_limit: log_limit, ets_table_name: ets_table_name}}
  end
end
