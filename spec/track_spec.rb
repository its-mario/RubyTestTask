require 'track'
require 'spotify_client'
require_relative '../configs.rb'


describe Track do

    client = SpotifyClient.new(CLIENT_ID, CLIENT_SECRET)

    it 'default instacing' do
        track = Track.new({
            :name => 'Name',
            :id => "0000000000",
            :artist_name => "Artist Name",
            :album_name => "Album Name",
            :spotify_url => "https://open.spotify.com/track/0000000000"
        })
        expect(track.name).to eql('Name') 
        expect(track.id).to eql("0000000000") 
        expect(track.artist_name).to eql("Artist Name") 
        expect(track.album_name).to eql("Album Name") 
        expect(track.spotify_url).to eql("https://open.spotify.com/track/0000000000") 
    end

    it 'instacing using parse' do
        track = Track.parse(File.read("spec/fixtures/files/parse.json"))
        expect(track.name).to eql('Cut To The Feeling') 
        expect(track.id).to eql("11dFghVXANMlKmJXsNCbNl") 
        expect(track.artist_name).to eql("Carly Rae Jepsen") 
        expect(track.album_name).to eql("Cut To The Feeling") 
        expect(track.spotify_url).to eql("https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl") 
    end

    it 'instacing using id' do
        track = Track.by_id("11dFghVXANMlKmJXsNCbNl", client)
        expect(track.name).to eql('Cut To The Feeling') 
        expect(track.id).to eql("11dFghVXANMlKmJXsNCbNl") 
        expect(track.artist_name).to eql("Carly Rae Jepsen") 
        expect(track.album_name).to eql("Cut To The Feeling") 
        expect(track.spotify_url).to eql("https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl")
    end

    it 'should return json on calling to_json' do
        track = Track.new({
            :name => 'Name',
            :id => "0000000000",
            :artist_name => "Artist Name",
            :album_name => "Album Name",
            :spotify_url => "https://open.spotify.com/track/0000000000"
        })
        json = track.to_json
        parsed = JSON.parse(json)
        expect(parsed).to include('name')
        expect(parsed).to include('id')
        expect(parsed).to include('spotify_url')
        expect(parsed).to include('album_name')
        expect(parsed).to include('artist_name')
    end
end