defmodule ExDaasWeb.ApiController do
  alias ExDaas.Cache.Counter.Model, as: Counter
  alias ExDaas.Cmd.Model, as: Cmd

  use ExDaasWeb, :controller

  @ets_tables Counter.shard_count_tables(:ets)

  def show(conn, %{"id" => id} = _params) do
    json(conn, %{id: id, data: data(id)})
  end

  def create_or_update(conn, %{"id" => id, "data" => data} = _params) do
    {uid, table} = ets_table(id)

    json(conn, fetch(uid, data, table))
  end

  def cmd(conn, %{"id" => id, "cmd" => cmd} = _params) do
    %{"query" => query, "keys" => keys} = cmd

    case Cmd.exe(query, keys, data(id)) do
      :error ->
        conn
        |> put_status(500)
        |> json(%{message: "#{query} not supported"})

      data ->
        json(conn, data)
    end
  end

  defp fetch(id, data, ets_table) do
    ExDaas.Ets.Table.fetch(id, data, ets_table)
  end

  defp data(id) do
    {_uid, table} = ets_table(id)
    [{_id, data}] = :ets.lookup(table, id)

    data
  end

  defp ets_table(id) do
    uid = Counter.new_id(id)
    shard = rem(uid, length(@ets_tables))

    {uid, Enum.at(@ets_tables, shard)}
  end
end
