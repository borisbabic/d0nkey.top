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
## Environment variables

If you use direnv you can just add the following
```
export BNET_CLIENT_SECRET='' 
export DISCORD_TOKEN=''
export TWITCH_CLIENT_ID=''
export TWITCH_CLIENT_SECRET=''

```
The above are required for running the site in development. Some features (like patreon integration) will require additional info if you want to use them.
## Dependencies

See elixir_buildpack.config for elixir and erlang versions
docker, docker-compose (or an appropriate postgres running)
npm 

You can use the shell.nix provided, possibly in combination with direnv

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


## First run
```shell
mix deps.get # install dependencies
docker-compose up -d # get postgres running
mix setup # setup the db
mix run -e Backend.MastersTour.fetch # optional, fetches the currently invited players
cd assets && npm install && cd ..
mix phx.server # start the server at port 8994. Open http://localhost:8994/leaderboard
```

