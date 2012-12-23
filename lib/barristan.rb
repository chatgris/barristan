# encoding: utf-8
module Barristan
  class Able
    def can(klasses, action, &block)
      Array(klasses).each do |klass|
        Barristan::Can.send(:define_method, "#{action}_#{klass.to_s.downcase}?",
                            block || lambda {|r, u| true })
      end
    end
  end

  class Can
    attr :resource, :action, :user, :klass
    private :resource, :action, :user, :klass

    def initialize(resource, action, user)
      @resource = resource
      @klass    = resource.class == Class ? resource : resource.class
      @action   = action
      @user     = user
    end

    def able?
      send("#{action}_#{klass.to_s.downcase}?", resource, user)
    end
  end

  class Guarded
    def forbidden(&block)
      @forbidden = block
    end

    def authorized(&block)
      @authorized = block
    end

    def authorized!
      @authorized.call
    end

    def forbidden!
      @forbidden.call
    end
  end

  class Acl
    class << self
      def new(&block)
        yield Able.new
        Barristan.module_eval do
          def guard(resource, action, user)
            yield(guarded = Guarded.new)
            Can.new(resource, action, user).
              able? ? guarded.authorized! : guarded.forbidden!
          end
        end
        Barristan
      end
    end
  end
end
