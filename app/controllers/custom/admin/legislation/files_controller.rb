class Admin::Legislation::FilesController < Admin::Legislation::BaseController
  def show
    @process = ::Legislation::Process.find(params[:id])

    WickedPdf.new.pdf_from_string(
      render :pdf => 'my_pdf_name',
      :template => "admin/legislation/files/content.pdf.erb",
      :header => {
        :content => render_to_string(:template => 'admin/legislation/files/header.pdf.erb', :layout => false)
      },
      :margin => {top: 33, bottom: 27, left: 20, right: 20}
    )
  end
end
