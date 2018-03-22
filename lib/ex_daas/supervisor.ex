defmodule ExDaas.Supervisor do
  alias ExDaas.Ets.Table, as: EtsTable
  alias ExDaas.Dets.Table, as: DetsTable

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    dets_tables = [
      :dets_table_one,
      :dets_table_two,
      :dets_table_three,
      :dets_table_four,
    ]

    children = [
      worker(EtsTable, [[name: EtsTable, dets_tables: dets_tables]]),
      worker(DetsTable, [[name: Enum.at(dets_tables, 0)]], [id: 1]),
      worker(DetsTable, [[name: Enum.at(dets_tables, 1)]], [id: 2]),
      worker(DetsTable, [[name: Enum.at(dets_tables, 2)]], [id: 3]),
      worker(DetsTable, [[name: Enum.at(dets_tables, 3)]], [id: 4]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
