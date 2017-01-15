class WelcomeController < ApplicationController

def index
	logger.debug "This is a Debug message"
	logger.info "This is an Info message"
	logger.warn "This is an Warn message"
end

end
