defmodule ExDaas.Cache.Model do
  alias ExDaas.Persist.Model, as: Persist

  @counter :user_id_counter
  @counter_table :dets_counter
  @table :exdaas_cache_table

  def fetch(id, data, dets_table) do
    case is_number(id) do
      true -> existing_data(id, data, dets_table)
      false -> new_user(data, dets_table)
    end
  end

  defp existing_data(id, data, dets_table) do
    case get(id) do
      {:not_found} ->
        %{id: id, data: set(id, data, dets_table)}
      {:found, id_data} ->
        %{id: id, data: already_in(id, data, id_data, dets_table)}
    end
  end

  def new_user(data, dets_tables) do
    new_count = increment_counter(@counter_table)

    dets_table = Enum.at(dets_tables, rem(new_count, length(dets_tables)))

    %{id: new_count, data: set(new_count, data, dets_table)}
  end

  def get(id) do
    case :ets.lookup(@table, id) do
      [] -> {:not_found}
      [{_id, data}] -> {:found, data}
    end
  end

  def load_from_dets(payload) do
    IO.puts "\nLOADING DATA FROM DETS INTO ETS\n"
    true = :ets.insert(@table, payload)
  end

  defp set(id, data, dets_table) do
    true = :ets.insert(@table, {id, data})
    Persist.create_or_update(id, data, dets_table)
    data
  end
  
  def remove_user(id, dets_table) do
    true = :ets.delete(id)
    Persist.delete(id, dets_table)
  end

  def set_counter(new_count, dets_table) do
    true = :ets.insert(@table, {@counter, new_count})
    Persist.create_or_update(@counter, new_count, dets_table)
    new_count
  end

  def increment_counter(dets_table) do
    case :ets.lookup(@table, @counter) do
      [] -> set_counter(1, dets_table)
      [{_counter, current_count}] -> set_counter(current_count + 1, dets_table)
    end
  end

  defp already_in(id, data, id_data, dets_table) do
    case Map.equal?(data, id_data) do
      true -> data
      false -> set(id, id_data, dets_table)
    end
  end
end
