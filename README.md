# Intro
www.d0nkey.top
A site for my hearthstone related endeavours

# Tech stack
- elixir, phoenix framework
- postgres
- cloudflare, hosted on hetzner using dokku

# Contributing
## Legal and licensing
Contributions should be provided under the Apache License. If I haven't yet added it the pull request template please badger me

## Code quality/style
There are pre-commit hooks available, see https://pre-commit.com/ for usage

Otherwise run check the format (`mix format`) and the static analysis (`mix credo`)

## Commits
https://chris.beams.io/posts/git-commit/#seven-rules
Please be guided by the seven rules when writing commit messages

# Running
## WSL setup
See [WSL Setup](WSL_SETUP.md) for instructions
## Environment variables
See the `.envrc.skel` for required and optional environment variables
For third parties (like discord/twitch) see their developer portals for how to get the tokens/secrets/ids

<!-- If you use direnv you can just add the following
```
export BNET_CLIENT_SECRET='' 
export DISCORD_TOKEN=''
export TWITCH_CLIENT_ID=''
export TWITCH_CLIENT_SECRET=''

```
The above are required for running the site in development. Some features (like patreon integration) will require additional info if you want to use them. -->
## Dependencies
### Flake
There is a flake.nix provided for dependencies, if using direnv ensure you have `use_flake` in your `.envrc`
Ensure you have nix installed and that you have the experimental features enabled by adding `experimental-features = nix-command flakes` to `~/.config/nix/nix.conf`
### Other
Ensure you have docker, docker-compose, relevant elixir/erlang versions (see the flake.nix for `erlangVersion` and `elixirVersion`)

If you are not using the flake.nix 
See elixir_buildpack.config for elixir and erlang versions
docker, docker-compose (or an appropriate postgres running)
npm 

You can use the shell.nix provided, possibly in combination with direnv

## First run
```shell
mix deps.get # install dependencies
docker-compose up -d # get postgres running
mix ecto.setup # setup the db
# mix run -e Backend.MastersTour.fetch # optional, fetches the currently invited players
cd assets && npm install && cd ..
mix assets.setup
iex -S mix phx.server # start the server at port 8994. Open http://localhost:8994/leaderboard
```
### Troubleshooting
#### :eacces
If you get an :eacces error that mentions `$PROJECT_DIR/_build/tailwind-linux-x64` run `chmod +x _build/tailwind-linux-x64` in the project dir


## API
### Resources
#### Deck Info
`archetype`: the deck archetype, without runes or XL
`name`: the name. The deck archetype or class with runes and XL
`deckcode`: canonical short deckcode used by the site

Example:
```json
{
  "archetype": "Control Priest",
  "deckcode": "AAECAa0GCOWwBKi2BJfvBO+RBYakBf3EBc/GBc2eBhCi6AOEnwShtgSktgSWtwT52wS43AS63ASGgwXgpAW7xAW7xwX7+AW4ngbPngbRngYAAQPwnwT9xAXFpQX9xAX++AX9xAUAAA==",
  "name": "XL Control Priest"
}
```

### Rest
#### GET "/api/cards/dust-free"
Responds with a list of ids of cards I have manually marked as dust free. I do this for cards that are dust free but not from sets that can be wholely marked as dust free. So basically free legendaries.

#### GET "/api/cards/collectible"
This is intended for when you want to have all information in your software and consult your stored info when you need it. If you intend to make requests on a per need basis (like every time somebody looks up a card) then use the official api instead

Responds with data primarily from the official hearthstone api but in one big json. I don't consider filtering these fully supported, but the same ones in /cards should work here.

WARNING: It's unlikely, but I may decide to not return fully filled out metadata in this and only return ids (like no spell_school just spell_school_id). Check the official api for obtaining metadata info in that case
#### GET "/api/cards/metadata"
Returns all metadata, based on the official api
#### GET "/api/deck-info/$DECKCODE"
Responds with 200 and a Deck Info resource for decodable deckcodes
Responds with 400 for undecodable deckcodes

example GET "/api/deck-info/AAEBAdH6AwLN9AKG+gMOlQGUA74Gnv0CvYUDtJcD2qUD8NQDqt4D1vUD+rQE9NAFwJ4G5p4GAAA="
response
```
{
    "archetype": "Even Shaman",
    "deckcode": "AAEBAaoIAs30Aob6Aw6VAZQDvgae/QK9hQO0lwPapQPw1AOq3gPW9QP6tAT00AXAngbmngYA",
    "name": "Even Shaman"
}
```

#### POST "/api/deck-info"
WARNING: This may currently not work and is considered low priority, if you would like this to be prioritized contact D0nkey, preferrable in their discord https://www.d0nkey.top/discord


Batch get deck info
Request format:
```json
{
  "decks": [$CODE1, $CODE2,...]
}
```
Response format:
```
{
  $CODE1: {deck_info resource},
  $CODE2: {deck_info resource},
  ...
}
```
The root keys are always the requested deckcode, not the canonical code found in the deck info resource. 
Undecodable deckcodes are ignored 

example POST "/api/deck-info"
Request Body
```json
{
    "decks": [
        "AAEBAdH6AwLN9AKG+gMOlQGUA74Gnv0CvYUDtJcD2qUD8NQDqt4D1vUD+rQE9NAFwJ4G5p4GAAA=",
        "This will be skipped",
        "### Multiline deckcode\nAAEBAa0GHOUEiA76DrW7ApO6A9fOA7TRA/jjA5HkA/voA9TtA62KBISfBISjBImjBIqjBIujBOWwBMeyBPTTBPXTBJrUBPrbBLjcBIaDBeKkBbvHBfv4BQH28AQA\n"
    ]
}
```
Response Body
```json
{
    "### Multiline deckcode\nAAEBAa0GHOUEiA76DrW7ApO6A9fOA7TRA/jjA5HkA/voA9TtA62KBISfBISjBImjBIqjBIujBOWwBMeyBPTTBPXTBJrUBPrbBLjcBIaDBeKkBbvHBfv4BQH28AQA\n": {
        "archetype": null,
        "deckcode": "AAEBAa0GHOUEiA76DrW7ApO6A9fOA7TRA/jjA5HkA/voA9TtA62KBISfBISjBImjBIqjBIujBOWwBMeyBPTTBPXTBJrUBPrbBLjcBIaDBeKkBbvHBfv4BQH28AQA",
        "name": "Priest"
    },
    "AAEBAdH6AwLN9AKG+gMOlQGUA74Gnv0CvYUDtJcD2qUD8NQDqt4D1vUD+rQE9NAFwJ4G5p4GAAA=": {
        "archetype": "Even Shaman",
        "deckcode": "AAEBAaoIAs30Aob6Aw6VAZQDvgae/QK9hQO0lwPapQPw1AOq3gPW9QP6tAT00AXAngbmngYA",
        "name": "Even Shaman"
    }
}
```

Note how the order is not preserved. Also to reiterate that the deckcode that is the root key for the shaman deck is the one that is requested, not the one returned in the deck info resource since the canonical deckcode is different


### Graphql
Graphql api is available at /api/graphql

GraphiQL playground should be available at /graphiql

Currently covered:
- streamer decks - (partial arguments/filters)