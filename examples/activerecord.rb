# frozen_string_literal: true

require 'active_record'
require 'sqlite3'
require 'rspec'

require_relative '../lib/rspec-benchmark'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'examples/db.sqlite3')

ActiveRecord::Schema.define do
  self.verbose = true

  create_table(:posts, force: true) do |t|
    t.string :title, null: false
    t.string :body

    t.timestamps
  end
end

class Post < ActiveRecord::Base
end

Post.delete_all

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe Post do
  let!(:post) { Post.create(title: 'Foo Bar') }

  it 'finds records quickly' do
    ActiveRecord::Base.transaction do
      expect { Post.find(post.id) }.to perform_under(50).ms.sample(10).times
    end
  end

  it 'finds posts that exist' do
    expect(Post.find(post.id)).to eq(post)
  end
end
