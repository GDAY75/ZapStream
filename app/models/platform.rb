class Platform < ApplicationRecord
  has_many :streams, dependent: :destroy

  validates :name, presence: true
end
