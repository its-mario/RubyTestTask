# RubyTestTask

### Install and run

```bash
bundle install
sudo gem install watir
```

then install broswer drivers for your system [Drivers – Watir Project](http://watir.com/guides/drivers/)

```bash
ruby bin/main.rb
```

**Don't forget to set *client_id* and  *clinet_secret* in 'bin/main.rb'** [My Dashboard | Spotify for Developers](https://developer.spotify.com/dashboard/login)  

## Output example

```json
{
    "name": "My new playlist",
    "description": "",
    "owner_name": "SherlockGames",
    "spotify_url": "https://open.spotify.com/playlist/2I1Y6f76250DknzN7Ck0ZU",
    "id": "2I1Y6f76250DknzN7Ck0ZU",
    "tracks": [
        {
            "id": "04lCbPtcGFnVcfLPshAvuC",
            "name": "Wannabe",
            "artist_name": "DEMONDICE",
            "album_name": "Kakigori Galaxy Astronaut",
            "spotify_url": "https://open.spotify.com/track/04lCbPtcGFnVcfLPshAvuC"
        },
        {
            "id": "7cYzdrwzYRZ1qKJLMQaw92",
            "name": "Princess♂",
            "artist_name": "TOPHAMHAT-KYO",
            "album_name": "Watery Autumoon",
            "spotify_url": "https://open.spotify.com/track/7cYzdrwzYRZ1qKJLMQaw92"
        },
        {
            "id": "1240iIrz36cDxTopJMi37h",
            "name": "Alkatraz",
            "artist_name": "DEMONDICE",
            "album_name": "Alkatraz",
            "spotify_url": "https://open.spotify.com/track/1240iIrz36cDxTopJMi37h"
        },
        {
            "id": "2kS6td1yvmpNgZTt1q5pQq",
            "name": "Hayloft",
            "artist_name": "Mother Mother",
            "album_name": "O My Heart",
            "spotify_url": "https://open.spotify.com/track/2kS6td1yvmpNgZTt1q5pQq"
        }
    ]
}
```