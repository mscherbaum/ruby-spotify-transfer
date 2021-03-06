require 'fuzzystringmatch'
require 'ostruct'

class AlbumsController < ApplicationController
  def show
  	spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
  	user_name = spotify_user.display_name
    session[:spotify_user] = spotify_user.to_hash    
  	
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
  	#logger.debug "this is the query object: " + query.to_s
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
    @match_list = @match_list.sort_by { |k| k["percentage"] }
  	logger.debug "This is the @match_list object: #{@match_list.inspect}"
  end

  def find_match_album(search_string)
  	result = RSpotify::Album.search(search_string).first
  	fuzzy = FuzzyStringMatch::JaroWinkler.create( :pure )	
	unless result.nil?
		#logger.debug "This is the result.name #{result.inspect}"		
		comparison_string = result.artists.first.name + " , " + result.name
  		match_percentage = fuzzy.getDistance(search_string,comparison_string)*100
  		#logger.debug "match_percentage: #{match_percentage.inspect}"
  		unless result.images[0].nil?
  			#logger.debug "This is the image object #{result.images[0].inspect}"
  			images = HashWithIndifferentAccess.new(result.images[0])
        result_image = images['url']
  			else
  			result_image = ""
  		end

  		unless result.id.nil?
  			result_id = result.id
        #logger.debug "This is the result.id object #{result.inspect}"
  			#result_id = result.id
  			else
  				result_id = ""
  		end

  		result_object = OpenStruct.new({"search"=>search_string, "result"=>comparison_string, "percentage"=>match_percentage, "result_id"=>result_id,"image"=>result_image})
  	else
  		result_object = OpenStruct.new({"search"=>search_string, "result"=>"No album found", "percentage"=>0, "result_id"=>"","image"=>""})
  	end
  	#logger.debug "This is the result_object #{result_object.inspect}"
  	return result_object
  end

  def save_album
    params.each do |key,value|
      logger.warn "Param #{key}: #{value}"
    end
    albums_to_save = params[:album_Ids] || []
    #logger.debug "These are the selected albums #{albums_to_save.inspect}"

    found_albums = []
    albums_to_save.each do |album|
      found_album = RSpotify::Album.find(album)
      found_albums.push(found_album) unless found_album.nil?
    end
    #logger.debug "Show found albums #{found_albums}"
    spotify_hash = session[:spotify_user]
    spotify_user = RSpotify::User.new(spotify_hash)
    logger.debug "Print the spotify_user #{spotify_user.inspect}"
    spotify_user.save_albums!(found_albums) unless spotify_user.nil?

  end

end