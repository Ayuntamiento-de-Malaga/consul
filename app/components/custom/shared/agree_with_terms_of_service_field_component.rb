class Shared::AgreeWithTermsOfServiceFieldComponent < ApplicationComponent
  attr_reader :form
  delegate :new_window_link_to, to: :helpers

  def initialize(form)
    @form = form
  end

  private

    def label
      t("form.accept_terms",
        policy: new_window_link_to(t("form.policy"), "https://www.malaga.eu/informacion-general/politica-de-privacidad/"),
        conditions: new_window_link_to(t("form.conditions"), "/conditions"))
    end
end
