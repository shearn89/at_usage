class ErrorsController < ApplicationController
  def render_not_found
    logger.error("invalid route requested: #{params[:a]}")
    render :template => "/errors/404.html.erb", :status => 404
  end
end
