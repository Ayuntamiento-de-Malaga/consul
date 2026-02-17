class Admin::Legislation::FilesController < Admin::Legislation::BaseController
  def show
    @process = ::Legislation::Process.find(params[:id])
    @conclusions = params[:conclusions]
    @area = params[:area]
    @type = params[:type]

    render :pdf => 'my_pdf_name',
      :disposition => 'attachment',
      :template => "admin/legislation/files/content",
      :formats => [:pdf],
      :header => {
        :content => render_to_string(:template => 'admin/legislation/files/header', :layout => false, :formats => [:pdf])
      },
      :footer => {
        :content => render_to_string(:template => 'admin/legislation/files/footer', :layout => false, :formats => [:pdf])
      },
      :margin => {top: 33, bottom: 40, left: 20, right: 20}
  end
end
