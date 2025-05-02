class AddLockableToDevise < ActiveRecord::Migration[6.1]
  def change
    # Only if lock strategy is :failed_attempts
    unless column_exists?(:users, :failed_attempts)
      add_column :users, :failed_attempts, :integer, default: 0, null: false
    end
    
    unless column_exists?(:users, :locked_at)
      add_column :users, :locked_at, :datetime
    end

    # Add these only if unlock strategy is :email or :both
    unless column_exists?(:users, :unlock_token)
      add_column :users, :unlock_token, :string
      add_index :users, :unlock_token, unique: true
    end
  end
end
