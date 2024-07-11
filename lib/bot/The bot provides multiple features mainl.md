The bot provides multiple features mainly for the video game Hearthstone and it's competitive scene.
Message content is used for !commands and a couple other things

* Card info. Card info for cards within [[]], example the bot would reply to "Wow, [[Ranger Reno]] really counters [[Rhea]]" with the cards `Reno, Lone Ranger` and `Rheastraza` https://i.imgur.com/qQrLZKX.png

* Deck info. Extracts decks from messages either based on deckcodes or links in the message with info about the, example the bot would reply to "What do you think about my theorycraft https://hearthstone.blizzard.com/deckbuilder?deckcode=AAECAZ8FAA%2FWgAaSoAbMsAaQ5AXBvwalswbOvwbJoATqqQabuAaO9QXrnwTrgAbunwSS1AQAAA%3D%3D" with a list of cards in the deck, number of copies, and other info about the deck https://i.imgur.com/XG6WXWf.png

* Redirects users to the new hearthstone wiki. The bot would reply to "How good is https://hearthstone.fandom.com/wiki/Battlegrounds/Kael'thas_Sunstrider" with a message stating the wiki has moved to hearthstone.wiki.gg and include a link to the equivalent page on the new wiki  https://i.imgur.com/QsvyrLH.png

* Small helper for discord timestamps based on ISO UTC dates, the bot would reply to "We're expecting the expansion to be released <t:2024-07-23 17:00:00:F>" with a message quoting the fake timesamp and containing <t:1721754000:F> - might be nice to add something like this to discord? where you can write timestamps in a date format? https://i.imgur.com/kQbPqKp.png
* Collects server battletags for use with some esports/competitive commands from a specific channel for that - This is the only info I currently save from messages, and it is unassociated with users only with the server

https://privatebin.net/?91b9e512e8dccc91#EA7ivnzP642Lm8Eqxj3YSJzB3E15fmatixWBqXgHfdMY

Commands that used saved info:
!ldb [battletags] [filters] - by default `!ldb` checks the hearthstone leaderboard information for the server favorited battletags. It's possible to specify battletags to check instead of the server favorited battletags https://i.imgur.com/XDbw8Y0.png

!battlefy $tournament_id - returns info about how players with the server favorited battletags are performing in the specificed battlefy.com tournament. There are also other shorthand commands for first party tournaments, ex `!mt` for the current masters tour. Some third party tournaments also get shorthands, and possibly tournament specific functionality https://i.imgur.com/JLnXkuI.png

Commands that don't use saved info
!cards [filters] - returns the latest hs cards https://i.imgur.com/zkraQMx.png

!card-stats [filters] - returns stats about hearthstone cards, like average minion attack/health for specified filters https://i.imgur.com/zn459NM.png

!reveals and !all-reveals - returns info about the current hearthstone reveal schedule, either the upcomingish reveals or all reveals for the reveal season https://i.imgur.com/zVml2ms.png

!patchnotes - returns a link to the latest HS patchnotes https://i.imgur.com/XzqFSA6.png

!thl - helper for teams in https://www.teamhearthleague.com/, primarily for team captains. Provides easily accessable links to discord profiles based on discord tags and membership in the THL discord. Only usable by members of the THL discord  https://i.imgur.com/2lA72zN.png