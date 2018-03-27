defmodule ExDaas.Supervisor do
  alias ExDaas.Ets.Table, as: EtsTable
  alias ExDaas.Ets.Counter.Table, as: EtsCounter
  alias ExDaas.Dets.Table, as: DetsTable

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def shard_calc do
    x_limit = 4

    shard_limit = 
      case System.get_env("SHARD_LIMIT") do
        nil -> x_limit
        num ->
          case Integer.parse(num) do
            {limit, _} -> limit
            :error -> x_limit
          end
      end

    0..shard_limit - 1
  end

  def init(:ok) do
    ets_table_names = shard_calc() |> Enum.map(fn i -> :"ets_table_#{i}" end)
    dets_table_names = shard_calc() |> Enum.map(fn i -> :"dets_table_#{i}" end)

    dets_tables = dets_table_names
    |> Enum.with_index
    |> Enum.map(fn {name, i} ->
      ets_table = Enum.at(ets_table_names, i)
      worker(DetsTable, [[name: name, ets_table: ets_table]], [id: name])
    end)

    ets_tables = ets_table_names
    |> Enum.with_index
    |> Enum.map(fn {name, i} ->
      dets_table = Enum.at(dets_table_names, i)
      worker(EtsTable,
        [[name: name, dets_table: dets_table]],
        [id: name]
      )
    end)

    counter_tables = [
      worker(EtsCounter, [[name: :ets_counter]], [id: :ets_counter]),
      worker(DetsTable,
        [[name: :dets_counter, ets_table: :ets_counter]],
        [id: :dets_counter]
      ),
    ]
    
    children = ets_tables ++ counter_tables ++ dets_tables
    
    supervise(children, strategy: :one_for_one)
  end
end
