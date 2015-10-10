module TooDone
  class Session < ActiveRecord::Base # written assuming pluralized table exists 
    belongs_to :user
  end
end
