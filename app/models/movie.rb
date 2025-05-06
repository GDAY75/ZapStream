class Movie < ApplicationRecord
  has_many :streams, dependent: :destroy

  validates :title, presence: true
end
