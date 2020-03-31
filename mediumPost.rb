# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def create
    @post = Post.new(post_params)
    CreatePost.call(@post) do |success, failure|
      success.call { redirect_to posts_path, notice: 'Successfully created post.' }
      failure.call { render :new }
    end
  end
end

# app/services/create_post.rb
class CreatePost
  attr_reader :post

  def self.call(post, &block)
    new(post).call(&block)
  end

  def initialize(post)
    @post = post
  end
  private_class_method :new

  def call(&block)
    if post.save
      send_email
      track_activity
      yield(Trigger, NoTrigger)
    else
      yield(NoTrigger, Trigger)
    end
  end

  def send_email
    # Send email to all followers
  end

  def track_activity
    # Track in activity feed
  end
end

# app/services/trigger.rb
class Trigger
  def self.call
    yield
  end
end

# app/services/no_trigger.rb
class NoTrigger
  def self.call
    # Do nothing
  end
end
