require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, ENV['SPOTIFY_CLIENTID'],ENV['SPOTIFY_SECRET'], scope: 'user-read-email playlist-modify-public user-library-read user-library-modify'
end

OmniAuth.config.logger = Logger.new(STDOUT)
OmniAuth.logger.progname = "omniauth"