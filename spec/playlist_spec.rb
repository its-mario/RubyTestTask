require 'playlist'
require 'track'
require_relative '../configs.rb'

describe Playlist do

    # let (:client) { SpotifyClient.new(CLIENT_ID, CLIENT_SECRET) } 

    client = SpotifyClient.new(CLIENT_ID, CLIENT_SECRET)
    
    context 'when is instanced' do
        playlist = Playlist.new({
            :spotify_url => "https://open.spotify.com/playlist/11PBG8oxvAY6Obk6yYGio2",
            :spotify_client => client 
        })

        it 'should add tracks to end of list' do
            initalNr = playlist.tracks.length
            playlist.add([
                Track.to_uri("61kTS7t3eXn2R6ZsYUKbj2"),
                Track.to_uri("6CRX3ENpLq42r0iBSjOqr1"),
            ])
            expect(playlist.tracks.length).to eq(initalNr + 2)
        end

        it "should move a track `from` `to`" do
            id_first_item = playlist.tracks[0].id
            playlist.move(0,-1)
            expect(playlist.tracks[-1].id).to eq(id_first_item)
        end

        it "should remove a track from postion" do
            initial_length = playlist.tracks.length
            playlist.remove(-1)
            if playlist.tracks.length == 0 then
                expect(playlist.tracks.length).to eq(initial_length)
            else
                expect(playlist.tracks.length < initial_length).to eq(true)
            end
        end

        it 'should return json object on calling .to_json' do
            json = JSON.parse(playlist.to_json)
            expect(json).to include('id')
            expect(json).to include('name')
            expect(json).to include('description')
            expect(json).to include('owner_name')
            expect(json).to include('tracks')
            expect(json).to include('spotify_url')
            if json['tracks'].length > 0 then
                expect(json['tracks'][0]).to include('name')
                expect(json['tracks'][0]).to include('id')
                expect(json['tracks'][0]).to include('spotify_url')
                expect(json['tracks'][0]).to include('album_name')
                expect(json['tracks'][0]).to include('artist_name')
            end
        end
        
    end 

    context 'Instancing' do
        it 'instancig using spotify_url' do
            playlist = Playlist.new({
                :spotify_url => "https://open.spotify.com/playlist/6Rg4NBQhLoeO4bQCCoxFz6?si=43d03f338b5e4290",
                :spotify_client => client,
            })
            expect(playlist.id).to eq("6Rg4NBQhLoeO4bQCCoxFz6")
        end

        it 'instacing using id' do 
            playlist = Playlist.new({
                :playlist_id => "6Rg4NBQhLoeO4bQCCoxFz6",
                :spotify_client => client,
            })
            expect(playlist.name).to eq("Test Playlist")
            expect(playlist.spotify_url).to eql("https://open.spotify.com/playlist/6Rg4NBQhLoeO4bQCCoxFz6")
        end

        it 'instacing using name' do
            playlist = Playlist.new({
                :name => "Test Playlist",
                :spotify_client => client 
            })
            expect(playlist.name).to eq("Test Playlist")
        end

        xit 'error instacing with out arguments' do
            expect(Playlist.new({
                :spotify_client => client
            })).to raise_error(ArgumentError)
        end

    end
    
end