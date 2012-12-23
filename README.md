# barristan

barristan is a minimal authorization system build in Ruby.

## Installation

Ruby 1.9.2 is required.

Install it with rubygems:

    gem install barristan

With bundler, add it to your `Gemfile`:

``` ruby
gem "barristan"
```

## Usage

``` ruby
class Controller
  include Barristan::Acl.new {|acl|
    acl.can Post, :index
    acl.can [Post], :new do |post, user|
      !!user
    end

    acl.can Post, :update do |post, user|
      post.user == user || user.admin?
    end
  }

  attr :current_user

  def initialize(user = nil)
    @current_user = user
  end

  def index
    guard Post, :index, current_user do |guarded|
      guarded.authorized { "success" }
      guarded.forbidden  { raise Forbidden.new }
    end
  end

  def update
    guard @post = Post.new, :update, current_user do |guarded|
      guarded.authorized { @post.update }
      guarded.forbidden  { raise Forbidden.new }
    end
  end
end
```
