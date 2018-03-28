# ExDaas

Elixir Database as a Service

Serialized - fault tolerant - self caching - self sharding - NoSQL DB :rocket:

Provides a RESTful API that can handle concurrent requests (Phoenix) but serializes all writes to disk.

All serialized writes can be split up by amount of shards.

Default shard size is 4. Any other wanted size can be set via `SHARD_LIMIT` (Any number above 0).

DiskIO is delegated via [DETS](http://erlang.org/doc/man/dets.html) and all cache is handled using [ETS](https://elixir-lang.org/getting-started/mix-otp/ets.html).

If the entire app fails, the data is loaded form disk into cache, and performance is back to normal.

Example supervision tree of a default shard size (4):

![](https://user-images.githubusercontent.com/9837366/37997853-005b93e0-31e2-11e8-9fe7-0e33eb54f943.PNG) 

_Suprisingly performant_ :smile:

<!--
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
-->

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

### Backing up data

1. Tarball: `./scripts/archive.tar.sh`
2. Zip: `./scripts/achrive.zip.sh`

### Current Benchmarks

~12k req/s in an Alpine Docker Container running on Ubuntu 17.10 in production mode on a 2 Core Intel i7 from 2013

**CPU Info**

```bash
Model name:          Intel(R) Core(TM) i7-4558U CPU @ 2.80GHz
CPU(s):              4
On-line CPU(s) list: 0-3
Thread(s) per core:  2
Core(s) per socket:  2
Socket(s):           1
```

#### To run benchmarks

You will need two tabs/panes/shell for this:

1. Build the container and run it: `./scripts/test.sh`
2. Wait for: `Attaching to exdaas_prod_1`
3. Run the bench suite in a different shell/pane/tab: `./scripts/bench.sh`

#### Another Alternative for Benching

_Default sharding is set to 4_

```bash
./scripts/console.bench.sh
```

**If you want to increase the shard size**

_You may set `SHARD_LIMIT` to any positive number over 0_

```bash
SHARD_LIMIT=16 ./scripts/console.bench.sh
```

_Remember this is synchronous and using a stream or a parallel map can be more realistic_

```elixir
alias ExDaas.Ets.Table, as: EtsTable

data = %{color: "blue"}

# if you changed SHARD_LIMIT
# ex: SHARD_LIMIT=24
# change 0..3 to 0..23 (or limit - 1)
ets_tables = 0..3 |> Enum.map(fn i -> :"ets_table_#{i}" end)

# this will be cold cache
0..20_000 |> Enum.each(fn i ->
  table_id = rem(i, length(ets_tables))
  EtsTable.fetch(i, data, Enum.at(ets_tables, table_id))
end)

# this will be warm cache
0..20_000 |> Enum.each(fn i ->
  table_id = rem(i, length(ets_tables))
  EtsTable.fetch(i, data, Enum.at(ets_tables, table_id))
end)
```

Exit the shell and `rm dets_*`

### LICENSE

**MIT**

See: `LICENSE` file in root of project
