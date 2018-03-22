defmodule ExDaas.Ets.Table do
  alias ExDaas.Cache.Model, as: Model

  use GenServer

  def start_link(opts \\ []) do
    [_, dets_tables: dets_tables] = opts

    GenServer.start_link(__MODULE__, [
      {:ets_table_name, :exdaas_cache_table},
      {:log_limit, 1_000_000},
      {:dets_tables, dets_tables},
      {:position, 0},
    ], opts)
  end

  def fetch(id, data) do
    GenServer.call(__MODULE__, {:fetch, {id, data}})
  end

  def update_pos_state(state, dets_tables, position) do
    case (position + 1) == length(dets_tables) do
      true -> Map.put(state, :position, 0)
      false -> Map.put(state, :position, position + 1)
    end
  end

  def handle_call({:fetch, {id, data}}, _from, app_state) do
    %{position: position, dets_tables: dets_tables} = app_state

    state = update_pos_state(app_state, dets_tables, position)

    %{position: new_position} = state

    # TODO
    # TODO

    # Instead of having a random table per request
    # Divide or Modulo by the id to ensure that data
    # always gets written to the same table for the same id
    
    # TODO
    # TODO

    {:reply,
      Model.fetch(id, data, Enum.at(dets_tables, new_position)),
     state}
  end

  def init(args) do
    [
      {:ets_table_name, ets_table_name},
      {:log_limit, log_limit},
      {:dets_tables, dets_tables},
      {:position, position},  
    ] = args
    
    :ets.new(ets_table_name, [
      :named_table,
      :set,
      :public,
    ])
    
    {:ok,
      %{
        log_limit: log_limit,
        ets_table_name: ets_table_name,
        dets_tables: dets_tables,
        position: position,
      },
    }
  end
end
