require_dependency Rails.root.join("app", "models", "officing", "residence").to_s

class Officing::Residence

  def allowed_age
    return if errors[:year_of_birth].any?
    return unless @census_api_response.valid?
  end

  private

    def residency_valid?
      @census_api_response.valid?
    end
end