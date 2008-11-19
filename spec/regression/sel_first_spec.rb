require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

if ADAPTER
  repository(ADAPTER) do
    class Person
      include DataMapper::Resource

      def self.default_repository_name
        ADAPTER
      end

      property :id,   Serial
      property :name, String
      
      has n, :cars
    end
    
    class Car
      include DataMapper::Resource

      def self.default_repository_name
        ADAPTER
      end

      property :id,    Serial
      property :name,  String
      property :color, String
      
      belongs_to :person
    end
  end

  describe 'Strategic eager loading with association.first() method' do
    before(:all) do
      
      Person.auto_migrate!(ADAPTER)
      Car.auto_migrate!(ADAPTER)
      
      @amanda = Person.create(:name => "Amanda")
      @oleg   = Person.create(:name => "Oleg")

      @black_audi   = Car.create(:color => "black", :name => "audi",     :person => @amanda)
      @red_maserati = Car.create(:color => "red",   :name => "maserati", :person => @amanda)
      @red_ferrari  = Car.create(:color => "red",   :name => "ferrari",  :person => @oleg)
      @blue_smart   = Car.create(:color => "blue",  :name => "smart",    :person => @oleg)
    end
    
    it "should filter the collection when query is given" do
      repository(ADAPTER) do
        
        # Eager load objects to the identity map
        @oleg   = Person.get(@oleg.id)
        @amanda = Person.get(@amanda.id)
        
        # Try to query amanda's car (black audi)
        @oleg.cars.first(:color => "black").should == nil
      end
    end

  end
end
