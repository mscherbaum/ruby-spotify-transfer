require 'fuzzystringmatch'
require 'ostruct'

class AlbumsController < ApplicationController
  def show
  	spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
  	user_name = spotify_user.display_name
  	
    if spotify_user.saved_albums.size >0
    	@albums = spotify_user.saved_albums
    else
    	@albums = RSpotify::Album.search('Gossip - A Joyful Noise')
    end

    if spotify_user.playlists.size >0
    	@playlists = spotify_user.playlists
    else
    	@playlists = Array.new
    end

    @user = spotify_user
  end

  def search
  	query = params[:message]
  	logger.debug "this is the query object: " + query.to_s
  	unless query.nil?
  		@submission = query.split("\r\n")
  	else
  		@submission == ["some text"]
  	end
  	@match_list = []  	
  	@submission.each do |album|
  		found_on_spotify = find_match_album(album)
  		@match_list.push(found_on_spotify)
  	end
  	logger.debug "This is the @match_list object: #{@match_list.inspect}"
  end

  def find_match_album(search_string)
  	result = RSpotify::Album.search(search_string).first
  	fuzzy = FuzzyStringMatch::JaroWinkler.create( :pure )
	
	unless result.nil?
  	match_percentage_1 = fuzzy.getDistance(result.name.to_s.join(result.artists.first.to_s),search_string)
  	match_percentage_2 = fuzzy.getDistance(search_string,result.name.to_s.join(result.artists.first.to_s))
  	logger.debug "match_percentage_1: #{match_percentage_1.inspect}"
  	logger.debug "match_percentage_2: #{match_percentage_2.inspect}"
  	result_object = OpenStruct.new({"search"=>search_string, "result"=>result.name, "percentage"=>match_percentage_1})
  	else
  	result_object = OpenStruct.new({"search"=>search_string, "result"=>"No album found", "percentage"=>0})
  	end  	
  	return result_object
  end


protected
  def auth_hash
    request.env['omniauth.auth']
  end
end