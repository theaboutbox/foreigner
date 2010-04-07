module FactoryHelpers
  class CreateCollection < ActiveRecord::Migration
    def self.up
      create_table :collections do |t|
        t.string :name
      end
    end

    def self.down
      drop_table :collections
    end
  end
end

module MigrationFactory

  # Creates a new anonymous migration and puts something into self.up
  # Example:
  #   migration = create_migration do
  #     create_table :items do |t|
  #       t.string :name
  #     end
  #   end
  def create_migration(&blk)
    migration = Class.new(ActiveRecord::Migration)

    # This is the equivalent of 
    # class Foo
    #   def self.up 
    #   end
    # end
    migration.metaclass.class_eval do
      define_method(:up, &blk)
    end
    migration
  end

  # Creates a new, anonymous table migration and activates it
  # Example:
  #   migration = create_table do |t|
  #     t.string :name
  #   end
  def create_table(table = :items, &blk)
    migration = create_migration do
      create_table(table, &blk)
    end
    migration.up 
  end

end

module ForeignKeyDefinitionFactory
  def valid_foreign_key_definition(opt = {})
    options = {
      :from_table => 'items',
      :to_table => 'collections'
    }.merge(opt)
    from_table = options.delete(:from_table)
    to_table = options.delete(:to_table)
    [from_table, to_table, options]
  end

  def new_foreign_key(opt = {})
    args = valid_foreign_key_definition(opt) 
    Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(*args)
  end
end
