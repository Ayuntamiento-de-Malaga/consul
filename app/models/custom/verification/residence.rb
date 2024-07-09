require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  validate :local_postal_code
  validate :local_residence

  before_validation :default_terms

  def local_postal_code
    errors.add(:postal_code, I18n.t("verification.residence.new.error_not_allowed_postal_code")) unless valid_postal_code?
  end

  def default_terms
    self.terms_of_service = true
  end

  def local_residence
    return if errors.any?

    unless residency_valid?
      errors.add(:local_residence, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  def save
    return false unless valid?

    user.take_votes_if_erased_document(document_number, document_type)

    user.update(document_number:       document_number,
                document_type:         document_type,
                geozone:               geozone,
                date_of_birth:         date_of_birth.in_time_zone.to_datetime,
                gender:                gender,
                residence_verified_at: Time.current,
                verified_at:           Time.current)
  end

  private

    def census_data
      @census_data = CensusCaller.new.call(document_type, base64_document(document_number), formated_date(date_of_birth), postal_code)
    end

    def residency_valid?
      census_data.valid? &&
        census_data.estado == 1
    end

    def clean_document_number
      self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase if document_number.present?
    end

    def base64_document(document)
      begin
        #for create
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
