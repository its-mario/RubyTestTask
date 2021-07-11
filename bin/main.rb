require_relative "../lib/playlist.rb"
require_relative "../lib/spotify_client.rb"
require_relative "../lib/track.rb"

CLIENT_ID = 'f702eb662a36476aa97ef15f5e39948b'
CLIENT_SECRET = '02271040a59e4e2aa1a70ed908a83e0f' 

client = SpotifyClient.new(CLIENT_ID, CLIENT_SECRET)
playlist = Playlist.new({:spotify_client => client, :name => "My new playlist"})

list_of_tracks = [
    Track.to_uri("2iscENxaM7EI43TVSyNUjz"),
    Track.to_uri("04lCbPtcGFnVcfLPshAvuC"),
    Track.to_uri("7cYzdrwzYRZ1qKJLMQaw92"),
    Track.to_uri("1240iIrz36cDxTopJMi37h"),
]

playlist.add(list_of_tracks)
playlist.move(0,-1)
playlist.remove(-1)

File.write("output.json", playlist.to_json)
