class Production < ApplicationRecord
  has_many :vtubers, dependent: :destroy
end
