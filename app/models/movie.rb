class Movie < ApplicationRecord
  has_many :sources
  has_and_belongs_to_many :actors
  has_many :genres_movies
  has_many :genres, through: :genres_movies
  belongs_to :director, optional: true

end
