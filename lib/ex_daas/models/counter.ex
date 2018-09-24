defmodule ExDaas.Cache.Counter.Model do
  @counter :counter
  @ets_counter :ets_counter
  @dets_counter :dets_counter

  @dets_root String.to_atom(System.get_env("DETS_ROOT") || "persistance_dir")

  def new_id(id) do
    case is_number(id) do
      true ->
        id

      false ->
        increment_counter()
    end
  end

  def set_counter(new_count) do
    true = :ets.insert(@ets_counter, {@counter, new_count})

    dets_root = :"#{@dets_root}/#{@dets_counter}"
    :ok = :dets.insert(dets_root, {@counter, new_count})
    
    new_count
  end

  def increment_counter() do
    case :ets.lookup(@ets_counter, @counter) do
      [] ->
        set_counter(1)

      [{_counter, current_count}] ->
        set_counter(current_count + 1)
    end
  end

  def shard_count_tables(type) do
    case Integer.parse(System.get_env("SHARD_LIMIT") || "") do
      :error ->
        0..3 |> make_tables(type)

      {limit, _} ->
        0..(limit - 1) |> make_tables(type)
    end
  end

  def dets_root do
    @dets_root
  end

  def make_tables(nums, type) do
    Enum.map(nums, fn i ->
      case type do
        :ets ->
          :"#{to_string(type)}_table_#{i}"

        :dets ->
          :"#{@dets_root}/#{to_string(type)}_table_#{i}"
      end
    end)
  end
end
