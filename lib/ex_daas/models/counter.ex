defmodule ExDaas.Cache.Counter.Model do
  @counter :counter
  @ets_counter :ets_counter
  @dets_counter :dets_counter

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
    :ok = :dets.insert(@dets_counter, {@counter, new_count})
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
end
