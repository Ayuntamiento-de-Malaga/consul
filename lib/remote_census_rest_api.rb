require 'rest-client'
include DocumentParser
class RemoteCensusRestApi
  def call(document_type, document_number, date_of_birth, postal_code)
    response = nil
    # Modificado para la API del Padrón de Málaga
    response = Response.new(get_response_body(document_type, base64_document(document_number), formated_date(date_of_birth), postal_code))
    puts 'remotecensusrestapi'
    puts response.inspect
    response
  end
  
  # Modificado para la API del Padrón de Málaga
  def base64_document(document)
    begin
      Base64.encode64(document).gsub(/\n/,"")
    rescue Exception => e
      puts e
    end
  end
  # Modificado para la API del Padrón de Málaga
  def formated_date(date)
    return unless date.present?
    begin
      day = date.day < 10 ? "0#{date.day}" : date.day
      month = date.month < 10 ? "0#{date.month}" : date.month
      date = "#{date.year}#{month}#{day}000000"
      date
    rescue Exception => e
      puts e
    end
  end

  class Response
    def initialize(body)
      @body = body
    end

    def extract_value(path_value)
      path = parse_response_path(path_value)
      return nil unless path.present?

      @body.dig(*path)
    end

    # Modificado para la API del Padrón de Málaga
    def valid?
      path_value = Setting["remote_census.response.valid"]
      extract_value(path_value) == "-1" && estado == 1
    end

    def date_of_birth
      path_value = Setting["remote_census.response.date_of_birth"]
      str = extract_value(path_value)
      return nil unless str.present?

      day, month, year = str.match(/(\d\d?)\D(\d\d?)\D(\d\d\d?\d?)/)[1..3]
      return nil unless day.present? && month.present? && year.present?

      Time.zone.local(year.to_i, month.to_i, day.to_i).to_date
    end

    def postal_code
      path_value = Setting["remote_census.response.postal_code"]
      extract_value(path_value)
    end

    def estado
      path_value = "par.estado"
      extract_value(path_value)
    end

    def district_code
      path_value = Setting["remote_census.response.district"]
      extract_value(path_value)
    end

    def gender
      path_value = Setting["remote_census.response.gender"]

      case extract_value(path_value)
      when "Male", "Varón"
        "male"
      when "Female", "Mujer"
        "female"
      end
    end

    def name
      path_value_name = Setting["remote_census.response.name"]
      path_value_surname = Setting["remote_census.response.surname"]

      "#{extract_value(path_value_name)} #{extract_value(path_value_surname)}"
    end

    def parse_response_path(path_value)
      path_value.split(".").map(&:to_sym) if path_value.present?
    end
  end

  private

    def get_response_body(document_type, document_number, date_of_birth, postal_code)
      if end_point_defined?
        request = request(document_type, document_number, date_of_birth, postal_code)
        headers = {'Content-Type' => 'application/json; charset=utf-8'}
        logger = Rails.logger
        logger.info request
        logger.info request.to_json
        response = RestClient::Request.execute(method: :post, headers: headers, url: Setting["remote_census.general.endpoint"],
                            payload: "#{request.to_json}")
        body = JSON.parse(response.body, :symbolize_names => true)
        body
      else
        stubbed_invalid_response
      end
    end

    def request(document_type, document_number, date_of_birth, postal_code)
      structure = JSON.parse(Setting["remote_census.request.structure"])

      fill_in(structure, Setting["remote_census.request.document_type"], document_type)
      fill_in(structure, Setting["remote_census.request.document_number"], document_number)
      fill_in(structure, Setting["remote_census.request.postal_code"], postal_code)
      if date_of_birth.present?
        fill_in(structure, Setting["remote_census.request.date_of_birth"], date_of_birth)
      end

      sec = {
          cli: Rails.application.secrets.census_api_cli,
          org: Rails.application.secrets.census_api_org,
          ent: Rails.application.secrets.census_api_ent,
          usu: Rails.application.secrets.census_api_usu,
          pwd: Rails.application.secrets.census_api_pwd
        }
      req_hash = {
        par: structure,
        sec: sec
      }
      req_hash
    end

    def fill_in(structure, path_value, value)
      path = parse_request_path(path_value)
      update_value(structure, path, value) if path.present?
    end

    def parse_request_path(path_value)
      path_value.split(".") if path_value.present?
    end

    def update_value(structure, path, value)
      *path, final_key = path
      to_set = path.empty? ? structure : structure.dig(*path)

      return unless to_set

      to_set[final_key] = value
    end

    def end_point_defined?
      Setting["remote_census.general.endpoint"].present?
    end

    def stubbed_invalid_response
      {}
    end
end
