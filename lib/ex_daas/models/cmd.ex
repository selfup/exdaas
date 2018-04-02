defmodule ExDaas.Cmd.Model do
  def exe(query, keys, data) do
    case query do
      "ONLY" ->
        only(keys, data)

      "FILTER_BOOL" ->
        filter_bool(keys, data)

      _not_supported ->
        :error
    end
  end

  defp only(keys, data) do
    values =
      Enum.map(keys, fn key ->
        Map.get(data, key)
      end)

    %{values: values}
  end

  defp filter_bool(keys, data) do
    %{"key" => key, "by" => by} = keys

    Map.get(data, key)
    |> Enum.filter(fn val -> Map.get(val, by) end)
  end
end
