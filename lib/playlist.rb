# frozen_string_literal: true

require_relative 'spotify_client'
require_relative 'track'
require_relative 'constants'
require 'uri'

# This class represent ruby implementation of spotify-playlist
class Playlist
  # There are several ways of instancing it :
  #   - using spotify-playlist-id
  #   - using spotify-playlist-url
  #   - using spotify-playlist-name (using just name will create new playlist)
  #
  #   it has several methods for managing tracks
  #   - move(from_position: Integer, to_positon: Integer) move track [from] postion [to] postion
  #       support negative values
  #   - remove(postion: Integer) for remove a specific postion in playlist
  #     because spotify_api support deleting only by uri on deleting a position it will delete all tracks with matching uri
  #   - add(spotify-uris-of-tracks: List<String>)

  attr_reader :id, :name, :description, :owner_name, :spotify_url, :tracks

  def initialize(args)
    @spotify_client = init_spotify_client(args)
    prepare_for_instacing args
  end

  # add to the end of playlist given tracks in spotify_uri format
  def add(uris_list)
    url = "https://api.spotify.com/v1/playlists/#{@id}/tracks"
    headers = {
      'Authorization' => TOKEN_TYPE + @spotify_client.token,
      'Content-Type' => 'application/json'
    }
    RestClient.post(url, { 'uris' => uris_list }.to_json, headers)
    get
  end

  # move track from a postion to another
  def move(from, to)
    length = @tracks.length
    url = "https://api.spotify.com/v1/playlists/#{@id}/tracks"
    headers = {
      'Authorization' => TOKEN_TYPE + @spotify_client.token,
      'Content-Type' => 'application/json'
    }
    to = (length + to + 1) if to.negative?
    RestClient.put(url, { 'range_start' => from, 'insert_before' => to }.to_json, headers)
    get
  end

  # remove a track from a specific postion
  def remove(position)
    url = "https://api.spotify.com/v1/playlists/#{@id}/tracks"
    headers = {
      'Authorization' => TOKEN_TYPE + @spotify_client.token,
      'Content-Type' => 'application/json'
    }
    return if @tracks[position].nil?

    uri = @tracks[position].to_uri
    payload = { 'tracks' => [{ 'uri' => uri }] }.to_json
    RestClient::Request.execute(method: :delete, url: url, headers: headers, payload: payload)
    get
  end

  def to_json(*options)
    {
      name: @name,
      description: @description,
      owner_name: @owner_name,
      spotify_url: @spotify_url,
      id: @id,
      tracks: @tracks
    }.to_json options
  end

  # calling it from instance will override this one
  def create(name)
    @name = name
    url = "https://api.spotify.com/v1/users/#{@spotify_client.user_id}/playlists"
    headers = {
      'Authorization' => TOKEN_TYPE + @spotify_client.token,
      'Content-Type' => 'application/json'
    }
    response = RestClient.post(url, { 'name' => @name }.to_json, headers)
    response = JSON.parse(response.body)
    @id = response['id']
    get
  end

  # update playlist data
  def get
    url = "https://api.spotify.com/v1/playlists/#{@id}"
    headers = { Authorization: TOKEN_TYPE + @spotify_client.token }
    response = JSON.parse(RestClient.get(url, headers))
    @description = response['description']
    @name = response['name']
    @owner_name = get_owner_name response['owner']['id']
    @spotify_url = response['external_urls']['spotify']
    @tracks = response['tracks']['items'].map { |item| Track.parse(item['track']) }
  end

  private

  def parse_id
    puts @spotify_url
    @id = URI(@spotify_url).path.delete_prefix('/playlist/')
  end

  def get_owner_name(user_id)
    url = "https://api.spotify.com/v1/users/#{user_id}"
    headers = { Authorization: TOKEN_TYPE + @spotify_client.token }
    begin
      response = RestClient.get(url, headers)
    rescue RestClient::ExceptionWithResponse
      # sometimes for unknown reasons it return Forbidden that's why i recall it again
      return get_owner_name user_id
    end
    response = JSON.parse(response.body)
    response['display_name']
  end

  def init_spotify_client(args)
    if args.include?(:spotify_client)
      args[:spotify_client]
    else
      SpotifyClient.new(args[:client_id], args[:client_secret])
    end
  end

  def prepare_for_instacing(args)
    if args.include?(:spotify_url)
      @spotify_url = args[:spotify_url]
      @id = parse_id
    elsif args.include?(:playlist_id)
      @id = args[:playlist_id]
    else
      raise ArgumentError, 'At least give a name for Playlist' if args[:name].nil?

      create args[:name]
    end
    get
  end
end
