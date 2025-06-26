require_dependency Rails.root.join("app", "models", "officing", "residence").to_s

class Officing::Residence

  def save
    return false unless valid?

    if user_exists?
      self.user = find_user_by_document
      user.update!(verified_at: Time.current)
    else
      user_params = {
        document_number: document_number,
        document_type: document_type,
        geozone: geozone,
        date_of_birth: response_date_of_birth&.in_time_zone.to_datetime,
        gender: gender,
        residence_verified_at: Time.current,
        verified_at: Time.current,
        erased_at: Time.current,
        password: random_password,
        terms_of_service: "1",
        email: nil
      }
      self.user = User.create!(user_params)
    end
  end

  def allowed_age
    return if errors[:year_of_birth].any?
    return unless @census_api_response.valid?
  end

  private

    def residency_valid?
      @census_api_response.valid?
    end
end