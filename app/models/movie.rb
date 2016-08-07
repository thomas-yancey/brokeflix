class Movie < ApplicationRecord
  has_many :sources
  has_and_belongs_to_many :actors
  has_and_belongs_to_many :genres
  belongs_to :director, optional: true

end
