require_relative 'spotify_client.rb'
require_relative 'track.rb'
TOKEN_TYPE = 'Bearer '

class Playlist
    attr_reader :id, :name, :description, :owner_name, :spotify_url
    attr_accessor :tracks

    def initialize args
        if args.include?(:spotify_client) then
            @spotify_client = args[:spotify_client]
        else
            @spotify_client = SpotifyClient(
                client_id: args[:client_id],
                client_secret:args[:client_secret]
            )
        end

        if args.include?(:spotify_url)  then
            @id = args[:playlist_id]
            self.get(method: :spotify_url)
        elsif args.include?(:playlist_id) then
            @spotify_url = :spotify_url
            self.get
        else
            raise "At least give a name for Playlist" if args[:name].nil?
            @name = args[:name]
            self.create
        end  
    end

    def add uris_list
        url = "https://api.spotify.com/v1/playlists/#{@id}/tracks"

        headers={
            "Authorization"=> TOKEN_TYPE + @spotify_client.token,
            "Content-Type"=> "application/json"
        }
        response = RestClient.post(
            url, {"uris" => uris_list}.to_json,
            headers = headers
        )
    end

    def move(from, to)
        #get the length of playlist
        length = self.get.length

        url = "https://api.spotify.com/v1/playlists/#{@id}/tracks"
        headers = {
            "Authorization"=> TOKEN_TYPE + @spotify_client.token,
            "Content-Type"=> "application/json"
        }
        to = (length + to + 1) if to < 0
        response = RestClient.put(
            url, 
            {"range_start"=> from , "insert_before"=> to }.to_json,
            headers
        )
        #update local instance 
        self.get
    end

    def remove position
        url = "https://api.spotify.com/v1/playlists/#{@id}/tracks"
        headers = {
            "Authorization"=> TOKEN_TYPE + @spotify_client.token,
            "Content-Type"=> "application/json"
        }
        #update loacal instance
        self.get
        uri = @tracks[position].to_uri
        payload = {"tracks" =>[{"uri" => uri}]}.to_json
        RestClient::Request.execute(
            :method => :delete,
            :url => url,
            :headers => headers,
            :payload => payload
        )
        self.get
    end

    def to_json
        self.get
        {
            :name => @name,
            :description => @description,
            :owner_name => @owner_name,
            :spotify_url => @spotify_url,
            :id => id,
            :tracks => @tracks#.map { | track | track.to_json}
        }.to_json
    end
    

    private

    

    def get
        self.parse_id unless @spotify_url.nil?
        url = "https://api.spotify.com/v1/playlists/#{id}"
        headers = {
            :Authorization => TOKEN_TYPE + @spotify_client.token
        }
        response = RestClient.get(url, headers)
        response = JSON.parse(response.body)
        @description = response['description']
        @name = response['name']
        @owner_name = self.get_owner_name response['owner']['id']
        @spotify_url = response['external_urls']['spotify']
        @tracks = response['tracks']['items'].map {| item | Track.new(item['track'])}  
    end 

    def get_owner_name user_id
        url = "https://api.spotify.com/v1/users/#{user_id}"
        headers = {
            :Authorization => TOKEN_TYPE + @spotify_client.token
        }
        response = RestClient.get(url, headers)
        response = JSON.parse(response.body)
        response['display_name']
    end

    def parse_id 
        uri = URI(@spotify_url)
        @id = uri.path.delete_prefix("/playlist/")
        @id
    end

    def create 
        url = "https://api.spotify.com/v1/users/#{@spotify_client.user_id}/playlists"
        headers={
            "Authorization"=> TOKEN_TYPE + @spotify_client.token,
            "Content-Type"=> "application/json"
        }
        response = RestClient.post(
            url,
            {"name"=> @name}.to_json,
            headers
        )
        response = JSON.parse(response.body)
        @id = response['id']
        self.get
    end
end