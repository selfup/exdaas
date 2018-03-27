defmodule ExDaas.Cache.Model do
  alias ExDaas.Persist.Model, as: Persist

  @counter :user_id_counter
  @counter_table :dets_counter

  def fetch(id, data, ets_table, dets_table) do
    existing_data?(id, data, ets_table, dets_table)
  end

  defp existing_data?(id, data, ets_table, dets_table) do
    case get(id, ets_table) do
      {:not_found} ->
        %{id: id, data: set(id, data, ets_table, dets_table)}
      {:found, id_data} ->
        %{id: id, data: already_in(id, data, id_data, ets_table, dets_table)}
    end
  end

  def get(id, ets_table) do
    case :ets.lookup(ets_table, id) do
      [] -> {:not_found}
      [{_id, data}] -> {:found, data}
    end
  end

  def load_from_dets(payload, ets_table) do
    IO.puts "\nLOADING DATA FROM DETS INTO ETS\n"
    true = :ets.insert(ets_table, payload)
  end

  defp set(id, data, ets_table, dets_table) do
    true = :ets.insert(ets_table, {id, data})
    Persist.create_or_update(id, data, dets_table)
    data
  end
  
  def remove_user(id, dets_table) do
    true = :ets.delete(id)
    Persist.delete(id, dets_table)
  end

  defp already_in(id, data, id_data, ets_table, dets_table) do
    case Map.equal?(data, id_data) do
      true -> data
      false -> set(id, id_data, ets_table, dets_table)
    end
  end
end
