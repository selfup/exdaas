defmodule ExDaasWeb.ApiController do
  alias ExDaas.Cache.Counter.Model, as: Counter

  use ExDaasWeb, :controller

  @ets_tables Counter.shard_count_tables(:ets)

  def show(conn, %{"id" => id} = _params) do
    {_uid, table} = ets_table(id)
    [{_id, data}] = :ets.lookup(table, id)

    json(conn, %{id: id, data: data})
  end

  def create_or_update(conn, %{"id" => id, "data" => data} = _params) do
    {uid, table} = ets_table(id)

    json(conn, fetch(uid, data, table))
  end

  defp fetch(id, data, ets_table) do
    ExDaas.Ets.Table.fetch(id, data, ets_table)
  end

  defp ets_table(id) do
    uid = Counter.new_id(id)
    shard = rem(uid, length(@ets_tables))

    {uid, Enum.at(@ets_tables, shard)}
  end
end
