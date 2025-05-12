require 'rails_helper'
require_relative '../../app/models/movie.rb'

RSpec.describe Movie, type: :model do
  it "is initialized with a hash of properties" do
    properties = { title: "Best movie ever", summary: "The best movie ever is about something incredibly simple." }
    movie = Movie.new(properties)
    expect(movie).to be_a(Movie)
  end

  it "is invalid when the values are nil" do
    movie = Movie.new( { title: "", summary: "" } )
    expect(movie).to be_invalid
  end
end
