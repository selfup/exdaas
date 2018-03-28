defmodule ExDaasWeb.ApiControllerTest do
  use ExDaasWeb.ConnCase

  setup do
    :ets.delete_all_objects(:ets_table_0) && :ets.delete_all_objects(:ets_table_1) &&
      :ets.delete_all_objects(:ets_table_2) && :ets.delete_all_objects(:ets_table_3) &&
      :dets.delete_all_objects(:dets_table_0) && :dets.delete_all_objects(:dets_table_1) &&
      :dets.delete_all_objects(:dets_table_2) && :dets.delete_all_objects(:dets_table_3) &&
      :ets.delete_all_objects(:ets_counter) && :dets.delete_all_objects(:dets_counter)
  end

  def post_query() do
    build_conn() |> post("/api", id: nil, data: %{color: "blue"})
  end

  def post_query(id) do
    build_conn() |> post("/api", id: id, data: %{color: "blue"})
  end

  def get_query(id) do
    build_conn() |> get("/api", id: id)
  end

  def only_cmd_query(id, query, keys) do
    build_conn() |> get("/api/cmd", id: id, cmd: %{query: query, keys: keys})
  end

  test "POST /api - increments count when different api make queries" do
    post_query()
    post_query()

    assert json_response(get_query(2), 200) == %{"id" => 2, "data" => %{"color" => "blue"}}
  end

  test "POST /api - keeps count to 1 when same user makes queries" do
    post_query(1)
    post_query(1)

    assert json_response(get_query(1), 200) == %{"id" => 1, "data" => %{"color" => "blue"}}
  end

  test "POST /api - slam api" do
    # 10k new records

    cold_time = :os.system_time(:seconds)

    0..20_000
    |> Enum.map(fn i -> Task.async(fn -> post_query(i) end) end)
    |> Enum.each(fn t -> Task.await(t) end)

    IO.puts("\n Cold slam seconds: #{:os.system_time(:seconds) - cold_time}")

    assert json_response(get_query(20_000), 200) == %{
             "id" => 20_000,
             "data" => %{"color" => "blue"}
           }

    # 10k identical records

    warm_time = :os.system_time(:seconds)

    0..20_000
    |> Enum.map(fn i -> Task.async(fn -> post_query(i) end) end)
    |> Enum.each(fn t -> Task.await(t) end)

    IO.puts(" Warm slam seconds: #{:os.system_time(:seconds) - warm_time}")

    assert json_response(get_query(10_000), 200) == %{
             "id" => 10_000,
             "data" => %{"color" => "blue"}
           }
  end

  test "GET /api/cmd - grabs on color from data Map" do
    post_query()

    result = json_response(only_cmd_query(1, "ONLY", ["color"]), 200)

    assert result == %{"values" => ["blue"]}
  end

  test "GET /api/cmd - returns 200 when more than one ONLY value is provided - even if value is invalid" do
    post_query()

    result = json_response(only_cmd_query(1, "ONLY", ["color", "uhh oh"]), 200)

    assert result == %{"values" => ["blue", nil]}
  end

  test "GET /api/cmd - returns 500 when query is not supported" do
    post_query()

    result = json_response(only_cmd_query(1, "NOPE", []), 500)

    assert result == %{"message" => "NOPE not supported"}
  end
end
