class Admin::DebatesTagsController < Admin::BaseController
  before_action :find_tag, only: [:update, :destroy]

  respond_to :html, :js

  def index
    @tags = Tag.area_or_district.page(params[:page])
    @tag  = Tag.new
  end

  def create
    Tag.find_or_create_by!(name: tag_params["name"]).update!(kind: tag_params["kind"])

    redirect_to admin_debates_tags_path
  end

  private

    def tag_params
      params.require(:tag).permit(:name, :kind)
    end

    def find_tag
      @tag = Tag.area_or_district.find(params[:id])
    end
end
