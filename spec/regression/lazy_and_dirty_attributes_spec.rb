require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

if ADAPTER
  repository(ADAPTER) do
    class Person
      include DataMapper::Resource

      def self.default_repository_name
        ADAPTER
      end

      property :id,        Serial
      property :name,      String
      property :address,   String, :lazy => true
      
      before :save do
        # load lazy attribute (emulate dm-validations)
        address
      end
      
    end
  end

  describe 'Lazy-loaded attributes during save process' do
    before(:all) do
      
      Person.auto_migrate!(ADAPTER)
      oleg = Person.create(:name => "Oleg", :address => "Some address")
      @oleg = Person.get(oleg.id)
    end
    
    it "should filter the collection when query is given" do
      repository(ADAPTER) do
        @oleg.name = "Oleg Andreev"
        @oleg.save
        @oleg = Person.get(@oleg.id)
        @oleg.name.should == "Oleg Andreev"
      end
    end

  end
end
