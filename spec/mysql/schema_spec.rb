ENV['RAILS_ENV'] ||= 'test_mysql'

require File.expand_path('../spec_helper.rb', File.dirname(__FILE__))

describe 'MySQL Adapter' do
  include MigrationFactory

  before(:each) do 
    @adapter = AdapterHelper::MySQLTestAdapter.new
  end

  describe 'when creating tables' do 
    before(:each) do
      @adapter.recreate_test_environment
    end
    
    it 'should understand t.foreign_key ' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :null => false
        t.foreign_key :collection
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\)/)
    end

    it 'should accept a :column parameter' do
      @column = :item_farm_id

      create_table :items do |t|
        t.string :name
        t.integer :item_farm_id
        t.foreign_key :collection, :column => @column
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`#{@column}\`\) REFERENCES \`collections\`\s*\(\`id\`\)/)
    end

    it 'should accept :depenent => :nullify' do
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => :nullify
      end     
      
      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE SET NULL/)
    end

    it 'should accept :dependent => :delete' do
      create_table :items do |t|
        t.string :name
        t.references :collection
        t.foreign_key :collection, :dependent => :delete
      end     

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE CASCADE/)
    end

    it 'should accept a t.references constraint' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => true
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\)/)
    end

    it 'should accept :foreign_key => { :dependent => :nullify }' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => :nullify}
      end

      @adapter.schema(:items).match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE SET NULL/)
    end

    it 'should accept :foreign_key => { :dependent => :delete }' do
      create_table :items do |t|
        t.string :name
        t.references :collection, :foreign_key => {:dependent => :delete}
      end

      @adapter.schema(:items).should match(/FOREIGN KEY\s*\(\`collection_id\`\) REFERENCES \`collections\`\s*\(\`id\`\) ON DELETE CASCADE/)
    end
  end

end

