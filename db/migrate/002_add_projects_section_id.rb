class AddProjectsSectionId < Rails::VERSION::MAJOR < 5 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        add_column :projects, :section_id, :integer, :default => nil
    end

    def self.down
        remove_column :projects, :section_id
    end

end
