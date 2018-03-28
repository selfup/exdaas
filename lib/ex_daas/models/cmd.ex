defmodule ExDaas.Cmd.Model do
  def exe(query, keys, data) do
    case query do
      "ONLY" ->
        single_or_more(keys, data)

      _not_supported ->
        :error
    end
  end

  def single_or_more(keys, data) do
    case keys |> length do
      1 ->
        value = Map.get(data, Enum.at(keys, 0))

        %{values: [value]}

      _anything_greater_than_one ->
        values =
          Enum.map(keys, fn key ->
            Map.get(data, key)
          end)

        %{values: values}
    end
  end
end
