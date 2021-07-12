require 'rest-client'
require 'json'
require_relative 'spotify_client.rb'

TOKEN_TYPE = 'Bearer '

class Track

    attr_reader :id, :name, :artist_name, :album_name, :spotify_url

    def initialize args
        @id = args[:id]
        @name = args[:name]
        @artist_name = args[:artist_name]
        @album_name = args[:album_name]
        @spotify_url = args[:spotify_url]
        @as_hash = args
    end

    def self.to_uri(id)
        "spotify:track:" + id
    end

    def self.by_id (id, spotify_client)
        url = "https://api.spotify.com/v1/tracks/#{id}"
        headers={
            "Authorization"=> TOKEN_TYPE + spotify_client.token,
        }
        response = RestClient.get(url, headers)
        response = JSON.parse(response)
        self.parse(response)
    end

    def to_uri
        "spotify:track:" + @id
    end

    def to_json *options
        @as_hash.to_json options
    end

    
    def self.parse args
        #check type
        unless args.class == String or args.class == Hash then 
            raise "wrong type args must be of type Hash or String(JSON)" 
        end
        args = JSON.parse(args) if args.class == String
        #if track has more than one artist 
        if args['artists'].length > 1 then
            names = args['artists'].map { |artist| artist['name'] }
            artists = names.join(', ')
        else 
            artists = args['artists'][0]['name']  
        end
        album_name = args['album']['name']
        spotify_url = args['external_urls']['spotify']
        hash = {
            :id => args['id'],
            :name => args['name'],
            :artist_name => artists,
            :album_name => album_name,
            :spotify_url => spotify_url 
        }
        new(hash)
    end
end