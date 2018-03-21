# ExDaas

Elixir Database as a Service

Serialized - fault tolerant - self caching - NoSQL DB :rocket:

Provides a RESTful API that can handle concurrent requests (Phoenix) but serializes all writes to disk.

DiskIO is delegated via DETS and all cache is handled using ETS.

_Suprisingly performant_ :smile:

### Deploying to Heroku

**You will need Docker for this**

Make sure the container builds!

`./scripts/prod.sh`

#### If not logged in to Heroku

```bash
heroku login
heroku container:login
```

Now: `APP_NAME=<app_name> heroku container:push web --app $APP_NAME`

#### Heroku Deploys after first successful login/push

Run: `./scripts/secret.sh && APP_NAME=<app_name> heroku container:push web --app $APP_NAME`

Or use the script: `APP_NAME=<app_name> ./scripts/heroku.sh`

### Deploying to Digital Ocean/Vultr/EC2

Make sure you have your ssh key as an authorized key for your target node!

#### Building a release with Docker

1. In one shell: `./scripts/docker.release.sh`
2. In another shell (once release is built): `./scripts/docker.copy.release.sh`
4. Grab tarball and scp: `scp -r ./exdaas.tar.gz user@<target_ip>:/home/user`
5. SSH into your server: `ssh user@<target_ip>`
6. Unpack the tarball: `tar -xzf exdaas.tar.gz`
7. Run the server:

        a. As a Daemon: `PORT=4000 ./bin/exdaas start`
        b. In the foreground: `PORT=4000 ./bin/exdaas foreground`
        c. In interactive mode: `PORT=4000 ./bin/exdaas console`

### Current Benchmarks

Mean 12.3k req/s in an Alpine Docker Container running on Ubuntu 17.10 in production mode on a 2 Core Intel i7 from 2014

#### To run benchmarks

You will need two tabs/panes/shell for this:

1. Build the container and run it: `./scripts/test.sh`
2. Wait for: `Attaching to exdaas_prod_1`
3. Run the bench suite in a different shell/pane/tab: `./scripts/bench.sh`

#### Another Alternative for Benching

```bash
if [ -f exdaas_persistance_table ]; then $(rm exdaas_persistance_table); fi \
  && iex -S mix phx.server
```

```elixir
alias ExDaas.Dets.Table, as: DetsTable

data = %{color: "blue"}

# this will be cold cache
0..20_000 |> Enum.each(fn i -> DetsTable.fetch(i, data) end)

# this will be warm cache
0..20_000 |> Enum.each(fn i -> DetsTable.fetch(i, data) end)
```

Exit the shell and `rm exdaas_persistance_table`

### LICENSE

**MIT**

See: `LICENSE` file in root of project
