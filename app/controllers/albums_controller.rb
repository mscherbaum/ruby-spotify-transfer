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
  		@submission = query.split("\n")
  	else
  		@submission == ["some text"]
  	end
  	logger.debug "This is the @submiision object: #{@submission.inspect}"
  end

protected
  def auth_hash
    request.env['omniauth.auth']
  end
end