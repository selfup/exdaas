defmodule ExDaas.Ets.Table do
  alias ExDaas.Cache.Model, as: Model

  use GenServer

  def start_link(opts \\ []) do
    [_, dets_tables: dets_tables] = opts

    GenServer.start_link(__MODULE__, [
      {:ets_table_name, :exdaas_cache_table},
      {:log_limit, 1_000_000},
      {:dets_tables, dets_tables},
    ], opts)
  end

  def fetch(id, data) do
    GenServer.call(__MODULE__, {:fetch, {id, data}})
  end

  def handle_call({:fetch, {id, data}}, _from, state) do
    %{dets_tables: dets_tables} = state

    case is_number(id) do
      true ->
        table = Enum.at(dets_tables, rem(id, length(dets_tables)))
        {:reply, Model.fetch(id, data, table), state}
      false ->
        {:reply, Model.new_user(data, dets_tables), state}
    end
  end

  def init(args) do
    [
      {:ets_table_name, ets_table_name},
      {:log_limit, log_limit},
      {:dets_tables, dets_tables},
    ] = args
    
    :ets.new(ets_table_name, [:named_table, :set, :public])
    
    {:ok,
      %{
        log_limit: log_limit,
        ets_table_name: ets_table_name,
        dets_tables: dets_tables,
        read_concurrency: true,
        write_concurrency: true,
      },
    }
  end
end
