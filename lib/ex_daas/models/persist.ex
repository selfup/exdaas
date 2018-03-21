defmodule ExDaas.Persist.Model do
  @table :exdaas_persistance_table

  def create_or_update(key, value) do
    :dets.insert(@table, {key, value})
  end

  def delete(id) do
    :dets.delete(@table, id)
  end
end
