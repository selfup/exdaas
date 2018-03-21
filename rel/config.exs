# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"Lo)lqpD/B<w4=]w6gKMxMP!%~:C|neoXTN}87UU)hRrtVQfb9o|_QNd%:ZY[9{tx"
end

release :exdaas do
  set version: current_version(:exdaas)
  set applications: [
    :runtime_tools
  ]
end
