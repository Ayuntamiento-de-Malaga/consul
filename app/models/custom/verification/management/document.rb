require_dependency Rails.root.join("app", "models", "verification", "management", "document").to_s

class Verification::Management::Document
  def in_census?
    response = CensusCaller.new.call(document_type, base64_document(document_number), formated_date(date_of_birth), postal_code)
    response.valid? && response.estado == 1
  end

  def base64_document(document)
    begin
      Base64.encode64(document).gsub(/\n/,"")
    rescue Exception => e
      puts e
    end
  end

  def formated_date(date)
    begin
      day = date.day < 10 ? "0#{date.day}" : date.day
      month = date.month < 10 ? "0#{date.month}" : date.month
      date = "#{date.year}#{month}#{day}000000"
      date
    rescue Exception => e
      puts e
    end
  end
end