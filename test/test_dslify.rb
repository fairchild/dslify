require "rubygems"
require "#{::File.dirname(__FILE__)}/../lib/dslify"
require "matchy"
require "context"

class Quickie
  include Dslify
  def parent(p=nil)
    p ? @p=p : @p
  end
end

class Dad
  include Dslify
  default_options(:curfew => 'midnight', :can => 'o ass wupin')
end

class QuickieTest < Test::Unit::TestCase
  context "setting" do
    before do
      @q = Quickie.new
    end
    it "should be able to set methods on self" do
      lambda{@q.bank "bobs"}.should_not raise_error
    end
    it "should set and then retrieve the same value back" do
      @q.snobs "are mean"
      @q.snobs.should == "are mean"
    end
    it "should set and retrieve values back with an = sign" do
      @q.author = "Ari Lerner"
      @q.author.should == "Ari Lerner"
    end
    it "should set these values in the h Hash on the object" do
      @q.movies "can be fun"
      @q.dsl_options.keys.should == [:movies]
    end
    it "should set multiple keys with set_vars_from_options" do
      @q.set_vars_from_options({:a => "a", :b => "b"})
      @q.a.should == "a"
      @q.b.should == "b"
    end
    it "should set methods even when they are called with a block" do
      @q.bobs Quickie.new do
      end
      @q.bobs.class.should == Quickie
    end
    it "should set the methods on the inner block" do
      @q.bobs Quickie.new do
        franks "franke"
      end
      @q.bobs.franks.should == "franke"
    end
  end
  
  context "default options" do
    before do
      @dad = Dad.new
      @dad.curfew= '11pm'
    end
    it "should be overridden if specified" do
      @dad.curfew.should == '11pm'
    end
    it "should be used if none set" do
      @dad.can.should == 'o ass wupin'
    end
    # TODO: Decide, do we want the below behavior?
    # it "should be able to set change default options" do 
    #   Dad.default_options(:name=>'fred')
    #   Dad.default_options.should == {:name=>'fred'}
    # end
    it "should be set on the class" do
      @dad.class.default_options.should == {:curfew => 'midnight', :can => 'o ass wupin'}
    end
  end
  
  context "should search parent for methods if there is a parent" do
      before do
        @dad = Dad.new
        @dad.car = 'gone'
        @kid = Quickie.new
        @kid.parent @dad
        @kid.curfew 'never'
      end
      it "should have a parent" do
        @kid.parent.nil?.should == false
        @kid.parent.should == @dad
      end
      it "should use the parents class method if method is missing on self" do
        @kid.respond_to?(:can).should == false
        @kid.can.should == 'o ass wupin'
      end
      it "should use its own methods if it has them" do
        @kid.curfew.should == 'never'
      end
      it "should not use parents instance methods" do
        @kid.respond_to?(:car).should == false
        @dad.car.should == 'gone'
      end
  end
  
  context "with inheritance and classes" do
    before do
      class Pop
        include Dslify
        def initialize(h={})
          dsl_options h
        end
        default_options :name => "pop"
      end
      class Foo < Pop
        default_options :name=>'fooey'
      end

      class Bar < Pop
        default_options :name=>'pangy', :taste => "spicy"
      end
      @pop = Pop.new
      @poptart = Pop.new :name => "Cinnamon"
      @foo = Foo.new
      @bar = Bar.new
    end
    it "should take the default options set on the class" do
      @pop.dsl_options[:name].should == "pop"
    end
    it "should allow us to add defaults on the instance by calling dsl_options" do
      @poptart.name.should == "Cinnamon"
    end
    it "should take the default options on a second class that inherits from the base" do
      @foo.name.should == "fooey"
    end
    it "should take the default options on a third inheriting class" do
      @bar.name.should == "pangy"
    end
    it "should not add a method not in the default_dsl_options" do
      @bar.respond_to?(:boat).should == false
    end
    it "should return the original default options test" do
      @bar.default_dsl_options[:taste].should == "spicy"
      @bar.default_dsl_options[:name].should == "pangy"
    end
  end
  
end