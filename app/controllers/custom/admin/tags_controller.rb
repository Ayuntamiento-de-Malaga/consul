class Admin::TagsController < Admin::BaseController
  before_action :find_tag, only: [:update, :destroy]

  respond_to :html, :js

  def index
    @tags = Tag.category.page(params[:page])
    @tag  = Tag.category.new
  end

  def destroy
    if @tag.category?
      @tag.destroy!
      redirect_to admin_proposals_tags_path
    else
      @tag.destroy!
      redirect_to admin_debates_tags_path
    end
  end

  private

    def tag_params
      params.require(:tag).permit(:name)
    end

    def find_tag
      @tag = Tag.find(params[:id])
    end
end
