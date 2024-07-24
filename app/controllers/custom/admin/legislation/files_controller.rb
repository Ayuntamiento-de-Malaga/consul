class Admin::Legislation::FilesController < Admin::Legislation::BaseController
  def show
    @process = ::Legislation::Process.find(params[:id])
    @conclusions = params[:conclusions]
    @area = params[:area]
    @type = params[:type]

    WickedPdf.new.pdf_from_string(
      render :pdf => 'my_pdf_name',
      :template => "admin/legislation/files/content.pdf.erb",
      :header => {
        :content => render_to_string(:template => 'admin/legislation/files/header.pdf.erb', :layout => false)
      },
      :footer => {
        :content => render_to_string(:template => 'admin/legislation/files/footer.pdf.erb', :layout => false)
      },
      :margin => {top: 33, bottom: 40, left: 20, right: 20}
    )
  end
end
