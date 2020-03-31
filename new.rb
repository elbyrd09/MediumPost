class PostsController < ApplicationController
  def create
    @post = Post.new(post_params)
    #Post is created under @post and verifies params
    CreatePost.call(@post) do |success, failure|
      #CreatePost class calls the call method (in the model) and passes the block @post as it's argument
      #which, if the params are correct, will save the post and send email + track activity
      #if you give a block that expects two arguments, the first will be executed only in success scenarios
      #and the second in failure scenarios. You keep everything clean and organized inside the same action.
      success.call { redirect_to posts_path, notice: 'Successfully created post.' }
      failure.call { render :new }
    end
  end
end
#skinny controller above ^ this is why CreatePost.call (and it's associated block) is the only code
# we end up needing to use in the controller which is a lot cleaner than everything that is included
# below in the model

#fat model below

# app/services/create_post.rb
class CreatePost
  attr_reader :post
    #no longer need to use an @ symbol to create an instance of post
  def self.call(post, &block)
    # ie. CreatePost.yield(post, &block)
    #in a function definition, &block captures any passed block into that object
    new(post).call(&block)
  end
  #CreatePost.call uses the call method below

  def initialize(post)
    @post = post
  end
  private_class_method :new
  #overrides the default behavior of the new method which is normally to
  # instantiate the new object of the class

#The CreatePost#call instance method (line 25) essentially accepts a block
#of code with success and failure as arguments (Line 5)

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


#We can pass a Trigger or NoTrigger class object as the success argument. If the success argument is given a Trigger class, the block given to success.call will be yielded which redirects the user request to the posts index page along with a success notice. However, if the success argument is given a NoTrigger class, the block given to it will not be called since NoTrigger.call class method does nothing. This entire logic applies to the failure argument as well.
