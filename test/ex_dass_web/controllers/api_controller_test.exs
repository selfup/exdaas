defmodule ExDaasWeb.UserControllerTest do
  use ExDaasWeb.ConnCase

  setup do
    :ets.delete_all_objects(:exdaas_cache_table) &&
    :dets.delete_all_objects(:dets_table_one)
  end

  def query() do
    build_conn() |> post("/api", id: nil, data: %{color: "blue"})
  end

  def query(id) do
    build_conn() |> post("/api", id: id, data: %{color: "blue"})
  end

  test "GET /api - increments count when different api make queries" do
    query()
    query()

    assert json_response(query(), 200) == %{"id" => 3, "data" => %{"color" => "blue"}}
  end

  test "GET /api - keeps count to 1 when same user makes queries" do
    query(1)
    query(1)

    assert json_response(query(1), 200) == %{"id" => 1, "data" => %{"color" => "blue"}}
  end
end
