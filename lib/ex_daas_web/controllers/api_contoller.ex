defmodule ExDaasWeb.ApiController do
  alias ExDaas.Cache.Counter.Model, as: Counter
  alias ExDaas.Cmd.Model, as: Cmd

  use ExDaasWeb, :controller

  @ets_tables Counter.shard_count_tables(:ets)

  def show(conn, %{"id" => id} = _params) do
    json(conn, %{id: is_num_or_nil(id), data: is_num_or_nil(id) |> data()})
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

    case :ets.lookup(table, id) do
      [] -> nil
      [{_id, data}] -> data 
    end
  end

  defp ets_table(id) do
    uid = is_num_or_nil(id) |> Counter.new_id()
    shard = rem(uid, length(@ets_tables))

    {uid, Enum.at(@ets_tables, shard)}
  end

  defp is_num_or_nil(id) do
    case is_number(id) do
      true -> id

      false ->
        case is_nil(id) do
          true -> nil

          false ->
            {num_id, _} = Integer.parse(id)
            num_id
        end
    end
  end
end
