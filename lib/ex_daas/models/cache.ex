defmodule ExDaas.Cache.Model do
  alias ExDaas.Persist.Model, as: PersistUser

  @counter :user_id_counter
  @table :exdaas_cache_table

  def fetch(id, data) do
    case is_number(id) do
      true -> existing_data(id, data)
      false -> new_user(data)
    end
  end

  defp existing_data(id, data) do
    case get(id) do
      {:not_found} ->
        %{id: id, data: set(id, data)}
      {:found, id_data} ->
        %{id: id, data: already_in(id, data, id_data)}
    end
  end

  defp new_user(data) do
    new_count = increment_counter()
    %{id: new_count, data: set(new_count, data)}
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

  defp set(id, data) do
    true = :ets.insert(@table, {id, data})
    PersistUser.create_or_update(id, data)
    data
  end
  
  def remove_user(id) do
    true = :ets.delete(id)
    PersistUser.delete(id)
  end

  def set_counter(new_count) do
    true = :ets.insert(@table, {@counter, new_count})
    PersistUser.create_or_update(@counter, new_count)
    new_count
  end

  def increment_counter() do
    case :ets.lookup(@table, @counter) do
      [] -> set_counter(1)
      [{_counter, current_count}] -> set_counter(current_count + 1)
    end
  end

  defp already_in(id, data, id_data) do
    case Map.equal?(data, id_data) do
      true -> data
      false -> set(id, id_data)
    end
  end
end
