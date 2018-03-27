defmodule ExDaasWeb.ApiController do
  alias ExDaas.Cache.Counter.Model, as: Counter
  use ExDaasWeb, :controller

  @en 0..3 |> Enum.map(fn i -> :"ets_table_#{i}" end)

  def find(conn, %{"id" => id, "data" => data} = _params) do
    uid = Counter.new_id(id)
    shard = rem(uid, length(@en))

    json conn, fetch(uid, data, Enum.at(@en, shard))
  end

  defp fetch(id, data, ets_table) do
    ExDaas.Ets.Table.fetch(id, data, ets_table)
  end
end
