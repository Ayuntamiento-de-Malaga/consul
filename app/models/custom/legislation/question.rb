require_dependency Rails.root.join("app", "models", "legislation", "question").to_s

class Legislation::Question
    def comments_for_verified_residents_only?
        false
    end
end