load Rails.root.join("app", "models", "legislation", "question.rb")

class Legislation::Question
    def comments_for_verified_residents_only?
        false
    end
end