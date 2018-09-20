class ApplicationController < ActionController::Base
	def index
		if !current_user
			#redirect_to "http://www.rubyonrails.org"
			redirect_to new_user_session_path
		end
	end
end
