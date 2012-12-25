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

And then, run `bundle`.

## Complete sinatra example

In a file called `config.ru`:

``` ruby
require 'sinatra'
require 'barristan'

User = Struct.new(:role) do
  def admin?
    role == 'admin'
  end
end

class Home < Sinatra::Base
  include Barristan::Acl.new {|acl|
    acl.can Home, :index do |app, user|
      user.admin?
    end
  }

  helpers do
    def current_user
      User.new(params[:role])
    end
  end

  get '/' do
    guard self.class, :index, current_user do |guarded|
      guarded.authorized { 'authorize' }
      guarded.forbidden  { halt 401 }
    end
  end

end

run Home
```

Run: `rackup`.

Let's check it with `curl`

``` shell
curl -i "http://localhost:9292"
# HTTP/1.1 401 Unauthorized
curl -i "http://localhost:9292?role=admin"
# HTTP/1.1 200 OK
```

## Usage

``` ruby
class Controller
  include Barristan::Acl.new {|acl|
    acl.can Post, :index
    acl.can [Post, Comment], :new do |post, user|
      !!user
    end

    acl.can Post, :update do |post, user|
      post.user == user || user.admin?
    end
  }

  def update
    guard @post = Post.new, :update, current_user do |guarded|
      guarded.authorized { @post.update }
      guarded.forbidden  { raise  }
    end
  end
end
```
