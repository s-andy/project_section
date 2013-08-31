class AddProjectsSectionId < ActiveRecord::Migration

    def self.up
        add_column :projects, :section_id, :integer, :default => nil
    end

    def self.down
        remove_column :projects, :section_id
    end

end
