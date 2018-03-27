defmodule ExDaasWeb.ApiControllerTest do
  use ExDaasWeb.ConnCase

  setup do
    :ets.delete_all_objects(:"ets_table_0") &&
    :ets.delete_all_objects(:"ets_table_1") &&
    :ets.delete_all_objects(:"ets_table_2") &&
    :ets.delete_all_objects(:"ets_table_3") &&
    :dets.delete_all_objects(:dets_table_0) &&
    :dets.delete_all_objects(:dets_table_1) &&
    :dets.delete_all_objects(:dets_table_2) &&
    :dets.delete_all_objects(:dets_table_3) &&
    :ets.delete_all_objects(:"ets_counter") &&
    :dets.delete_all_objects(:"dets_counter")
  end

  def query() do
    build_conn() |> post("/api", id: nil, data: %{color: "blue"})
  end

  def query(id) do
    build_conn() |> post("/api", id: id, data: %{color: "blue"})
  end

  test "POST /api - increments count when different api make queries" do
    query()
    query()

    assert json_response(query(), 200) == %{"id" => 3, "data" => %{"color" => "blue"}}
  end

  test "POST /api - keeps count to 1 when same user makes queries" do
    query(1)
    query(1)

    assert json_response(query(1), 200) == %{"id" => 1, "data" => %{"color" => "blue"}}
  end

  test "POST /api - slam api" do
    # 10k new records

    cold_time = :os.system_time(:seconds)
    0..20_000
    |> Enum.map(fn i -> Task.async(fn -> query(i) end) end)
    |> Enum.each(fn t -> Task.await(t) end)
    IO.puts "\n Cold slam seconds: #{:os.system_time(:seconds) - cold_time}"

    assert json_response(query(20_000), 200) == %{"id" => 20_000, "data" => %{"color" => "blue"}}

    # 10k identical records

    warm_time = :os.system_time(:seconds)
    0..20_000
    |> Enum.map(fn i -> Task.async(fn -> query(i) end) end)
    |> Enum.each(fn t -> Task.await(t) end)
    IO.puts " Warm slam seconds: #{:os.system_time(:seconds) - warm_time}"

    assert json_response(query(10_000), 200) == %{"id" => 10_000, "data" => %{"color" => "blue"}}
  end
end
