require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe Foreigner::ConnectionAdapters::PostgreSQLAdapter do
  include MigrationFactory

  before(:each) do 
    @adapter = AdapterHelper::PostgreSQLTestAdapter.new
    @adapter.recreate_test_environment
  end

  describe 'when creating tables with t.foreign_key' do 

    it 'should understand t.foreign_key' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql('collection_id')
      foreign_key.options[:dependent].should be_nil
    end

    it 'should accept a :column parameter' do
      @column = :item_collection_id

      create_table :items do |t|
        t.string :name
        t.integer @column
        t.foreign_key :collection, :column => @column
      end

      foreign_key = @adapter.foreign_keys(:items)[0]
      foreign_key.to_table.should eql('collections')
      foreign_key.options[:primary_key].should eql('id')
      foreign_key.options[:column].should eql(@column.to_s)
      foreign_key.options[:dependent].should be_nil
    end

    xit 'should accept :dependent => :nullify' do
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => :nullify
      end     

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE SET NULL/)
    end

    xit 'should accept :dependent => :delete' do
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => :delete
      end     

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE CASCADE/)
    end
  end

  describe 'when creating tables with t.reference' do

    xit 'should accept a t.references constraint' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => true
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\)/)
    end

    xit 'should accept :foreign_key => { :dependent => :nullify }' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => :nullify}
      end

      @adapter.schema(:items).match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE SET NULL/)
    end

    xit 'should accept :foreign_key => { :dependent => :delete }' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => :delete}
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE CASCADE/)
    end
  end

end

