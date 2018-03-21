defmodule ExDaasWeb.ApiController do
  use ExDaasWeb, :controller

  def find_or_create(conn, %{"id" => id, "data" => data} = _params) do
    json conn, fetch(id, data)
  end

  defp fetch(id, data) do
    ExDaas.Dets.Table.fetch(id, data)
  end
end
