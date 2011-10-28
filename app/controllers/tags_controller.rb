class TagsController < ApplicationController

  def index
    @tags = Tag.paginate(params[:page] || 1)
    @youareat = "tags"
  end

  def search
    @tags = Tag.search(params[:keyword])
    render :layout => false
  end

end