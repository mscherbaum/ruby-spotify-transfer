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
	
	logger.debug "This is the result.name #{result.name}"
	#logger.debug "This is the result object #{result.inspect}"

	unless result.nil?
		comparison_string = result.artist.first.name + " , " result.name
  	match_percentage = fuzzy.getDistance(search_string,comparison_string)*100
  	logger.debug "match_percentage: #{match_percentage.inspect}"
  	result_object = OpenStruct.new({"search"=>search_string, "result"=>comparison_string, "percentage"=>match_percentage})
  	else
  	result_object = OpenStruct.new({"search"=>search_string, "result"=>"No album found", "percentage"=>0})
  	end

  	logger.debug "This is the result_object #{result_object.inspect}"
  	return result_object
  end


protected
  def auth_hash
    request.env['omniauth.auth']
  end
end