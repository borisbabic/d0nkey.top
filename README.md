# Intro
www.d0nkey.top
A site for my hearthstone related endeavours

# Tech stack
- elixir, phoenix framework
- postgres
- heroku, cloudfare

# Contributing
## Legal and licensing
Contributions should be provided under the Apache License. If I haven't yet added it the pull request template please badger me

## Code quality/style
There are pre-commit hooks available, see https://pre-commit.com/ for usage

Otherwise run check the format (`mix format`) and the static analysis (`mix credo`)

## Tests 
Test what makes sense to be tested :) (if I haven't yet added tests you can skip this :sweat_smile:)

## Commits
https://chris.beams.io/posts/git-commit/#seven-rules
Please be guided by the seven rules when writing commit messages

# Running
## Environment variables

If you use direnv you can just add the following
```
export BNET_CLIENT_SECRET='' 
export SIGNUP_TOKEN='' # battlefy token, for autosignup, not necessary
export DISCORD_TOKEN=''

```
## Dependencies

See elixir_buildpack.config for elixir and erlang versions
docker, docker-compose (or an appropriate postgres running)
npm 

You can use the shell.nix provided, possibly in combination with direnv and 

## API 

Graphql api is available at /api/graphql

GraphiQL playground should be available at /graphiql

Currently covered:
- streamer decks - (partial arguments/filters)


## First run
```shell
mix deps.get # install dependencies
docker-compose up -d # get postgres running
mix setup # setup the db
mix run -e Backend.MastersTour.fetch # optional, fetches the currently invited players
cd assets && npm install && cd ..
mix phx.server # start the server at port 8994. Open http://localhost:8994/leaderboard
```

