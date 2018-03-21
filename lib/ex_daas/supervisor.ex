defmodule ExDaas.Supervisor do
  alias ExDaas.Ets.Table, as: EtsTable
  alias ExDaas.Dets.Table, as: DetsTable

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(EtsTable, [[name: EtsTable]]),
      worker(DetsTable, [[name: DetsTable]]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
