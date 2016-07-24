class Movie < ApplicationRecord
  has_many :sources
  has_and_belongs_to_many :actors
  belongs_to :director, optional: true

end
