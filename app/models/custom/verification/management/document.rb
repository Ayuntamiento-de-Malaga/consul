load Rails.root.join("app", "models", "verification", "management", "document.rb")

class Verification::Management::Document
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :document_type, :document_number, :date_of_birth, :postal_code

  validates :document_type, :document_number, presence: true
  validates :date_of_birth, presence: true, if: -> { Setting.force_presence_date_of_birth? }
  validates :postal_code, presence: true, if: -> { Setting.force_presence_postal_code? }

  delegate :username, :email, to: :user, allow_nil: true

  def under_age?(response)
    puts 'under_age?'
    puts response.date_of_birth
    puts response.inspect
    return false if response.date_of_birth.blank?
    Age.in_years(response.date_of_birth) < User.minimum_required_age
  end
end
