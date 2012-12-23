# encoding: utf-8
require 'spec_helper'

describe Barristan do
  User = Struct.new(:name, :admin) do
    def admin?
      admin
    end
  end

  class Post
    def user
      "creator"
    end

    def update
    end
  end
  class Forbidden < Exception; end

  class Controller
    include Barristan::Acl.new {|acl|
      acl.can Post, :index
      acl.can [Post], :new do |post, user|
        !!user
      end
      acl.can Post, :update do |post, user|
        !!user && (post.user == user.name || user.admin?)
      end
    }

    attr :current_user

    def initialize(user = nil)
      @current_user = user
    end

    def index
      guard Post, :index, current_user do |guarded|
        guarded.authorized { "success" }
        guarded.forbidden { raise Forbidden.new }
      end
    end

    def new
      guard Post, :new, current_user do |guarded|
        guarded.authorized { "new" }
        guarded.forbidden { raise Forbidden.new }
      end
    end

    def update
      guard @post = Post.new, :update, current_user do |guarded|
        guarded.authorized { @post.update ; "success" }
        guarded.forbidden { raise Forbidden.new }
      end
    end
  end

  let(:user) { User.new("user", false) }
  let(:admin) { User.new("admin", true) }
  let(:creator) { User.new("creator", false) }

  context "current_user is nil" do
    it "should be able to call index" do
      Controller.new.index.should eq "success"
    end

    it "should not be able to call new" do
      expect {
        Controller.new.new
      }.to raise_error(Forbidden)
    end
    it "should not be able to call update" do
      expect {
        Controller.new.update
      }.to raise_error(Forbidden)
    end
  end

  context "user has admin properties" do
    it "should be able to call new" do
      Controller.new(admin).new.should eq "new"
    end

    it "should be able to call index" do
      Controller.new(admin).index.should eq "success"
    end

    it "should be able to call update" do
      Controller.new(admin).update.should eq "success"
    end
  end

  context "user has not admin properties" do
    it "should be able to call new" do
      Controller.new(user).new.should eq "new"
    end

    it "should be able to call index" do
      Controller.new(user).index.should eq "success"
    end

    context "post.user != current_user" do
      it "should not be able to call update" do
        expect {
          Controller.new(user).update
        }.to raise_error(Forbidden)
      end
    end

    context "post.user == current_user" do
      it "should not be able to call update" do
        Controller.new(creator).update.should eq "success"
      end
    end
  end
end
