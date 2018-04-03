defmodule ExDaas.Supervisor do
  alias ExDaas.Ets.Table, as: EtsTable
  alias ExDaas.Dets.Table, as: DetsTable
  alias ExDaas.Ets.Counter.Table, as: EtsCounter
  alias ExDaas.Cache.Counter.Model, as: Counter

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    ets_table_names = Counter.shard_count_tables(:ets)
    dets_table_names = Counter.shard_count_tables(:dets)

    dets_tables =
      dets_table_names
      |> Enum.with_index()
      |> Enum.map(fn {name, i} ->
        ets_table = Enum.at(ets_table_names, i)
        worker(DetsTable, [[name: name, ets_table: ets_table]], id: name)
      end)

    ets_tables =
      ets_table_names
      |> Enum.with_index()
      |> Enum.map(fn {name, i} ->
        dets_table = Enum.at(dets_table_names, i)
        worker(EtsTable, [[name: name, dets_table: dets_table]], id: name)
      end)

    ets_counter = :ets_counter
    dets_counter = :"#{Counter.dets_root}/dets_counter"

    counter_tables = [
      worker(
        EtsCounter,
        [[name: ets_counter]],
        id: ets_counter
      ),
      worker(
        DetsTable,
        [[name: dets_counter, ets_table: ets_counter]],
        id: dets_counter
      )
    ]

    children = ets_tables ++ counter_tables ++ dets_tables

    supervise(children, strategy: :one_for_one)
  end
end
