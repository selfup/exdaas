defmodule ExDaasWeb.Router do
  use ExDaasWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", ExDaasWeb do
    pipe_through(:api)

    post("/", ApiController, :create_or_update)

    get("/", ApiController, :show)
    get("/cmd", ApiController, :cmd)
  end
end
