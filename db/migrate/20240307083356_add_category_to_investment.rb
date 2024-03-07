class AddCategoryToInvestment < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_investments, :category, :string
  end
end
