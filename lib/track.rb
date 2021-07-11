require 'rest-client'
require 'json'

TOKEN_TYPE = 'Bearer '


class Track

    attr_reader :id, :name, :artis_name, :album_name, :spotify_url

    def initialize args
        parsed_args = self.parse(args)
        @id = parsed_args[:id]
        @name = parsed_args[:name]
        @artis_name = parsed_args[:artis_name]
        @album_name = parsed_args[:album_name]
        @spotify_url = parsed_args[:spotify_url]
        @attr_hash = parsed_args
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
        new(response)
    end

    def to_uri
        "spotify:track:" + @id
    end

    def to_json *options
        @attr_hash.to_json *options
    end

    def as_json
        @attr_hash
    end

    private
    def parse args
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
        {
            :id => args['id'],
            :name => args['name'],
            :artist_name => artists,
            :album_name => album_name,
            :spotify_url => spotify_url 
        }
    end
end