require_relative 'spotify_client.rb'
require_relative 'track.rb'
require 'uri'
TOKEN_TYPE = 'Bearer '

class Playlist
    attr_reader :id, :name, :description, :owner_name, :spotify_url
    attr_accessor :tracks

    def initialize args
        #create a spotify_client if it wasn't passed
        if args.include?(:spotify_client) then
            @spotify_client = args[:spotify_client]
        else
            @spotify_client = SpotifyClient.new(
                args[:client_id],
                args[:client_secret]
            )
        end
        
        if args.include?(:spotify_url)  then
            @spotify_url = args[:spotify_url]
            @id = self.parse_id
            self.get
        elsif args.include?(:playlist_id) then
            @id = args[:playlist_id]
            self.get
        else
            raise ArgumentError, "At least give a name for Playlist" if args[:name].nil?
            self.create args[:name]
        end  
    end

    #add to the end of playlist given tracks
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
        self.get
    end

    #move track from a postion to another
    def move(from, to)
        
        length = @tracks.length
        url = "https://api.spotify.com/v1/playlists/#{@id}/tracks"
        headers = {
            "Authorization"=> TOKEN_TYPE + @spotify_client.token,
            "Content-Type"=> "application/json"
        }
        to = (length + to + 1) if to < 0
        RestClient.put(
            url, 
            {"range_start"=> from , "insert_before"=> to }.to_json,
            headers
        )
        #update local instance 
        self.get
    end

    #remove a track from a specific postion
    def remove position
        
        url = "https://api.spotify.com/v1/playlists/#{@id}/tracks"
        headers = {
            "Authorization"=> TOKEN_TYPE + @spotify_client.token,
            "Content-Type"=> "application/json"
        }
        #update loacal instance in case 
        #if the instance is not more up-to-date
        if @tracks[position].nil? then
            return
        end
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

    #converting to json
    def to_json *options
        {
            :name => @name,
            :description => @description,
            :owner_name => @owner_name,
            :spotify_url => @spotify_url,
            :id => @id,
            :tracks => @tracks
        }.to_json options
    end

    #calling it from instance will override this one
    def create name
        #overriding @name needs for calling from instance
        @name = name
        user_id = @spotify_client.user_id
        url = "https://api.spotify.com/v1/users/#{user_id}/playlists"
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

    #get and parse data of playlist
    def get
        url = "https://api.spotify.com/v1/playlists/#{@id}"
        headers = {
            :Authorization => TOKEN_TYPE + @spotify_client.token
        }
        response = RestClient.get(url, headers)
        response = JSON.parse(response.body)
        @description = response['description']
        @name = response['name']
        @owner_name = self.get_owner_name response['owner']['id']
        @spotify_url = response['external_urls']['spotify']
        @tracks = response['tracks']['items'].map {| item | Track.parse(item['track'])}  
    end 
    
    private

    def parse_id 
        puts @spotify_url
        uri = URI(@spotify_url)
        @id = uri.path.delete_prefix("/playlist/")
    end
    
    def get_owner_name user_id
        url = "https://api.spotify.com/v1/users/#{user_id}"
        headers = {
            :Authorization => TOKEN_TYPE + @spotify_client.token
        }
        begin
        response = RestClient.get(url, headers)
        rescue RestClient::ExceptionWithResponse => e
            #sometimes for unknown reasons it return Forbidden thats why i recall it again
            return self.get_owner_name user_id
        end
        response = JSON.parse(response.body)
        response['display_name']
    end
end
