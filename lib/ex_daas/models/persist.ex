defmodule ExDaas.Persist.Model do
  def create_or_update(key, value, dets_table) do
    :dets.insert(dets_table, {key, value})
  end

  def delete(id, dets_table) do
    :dets.delete(dets_table, id)
  end
end
