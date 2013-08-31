class CreateProjectSections < ActiveRecord::Migration

    def self.up
        create_table :project_sections do |t|
            t.column :parent_id,  :integer
            t.column :lft,        :integer
            t.column :rgt,        :integer
            t.column :identifier, :string, :limit => 20, :null => false
            t.column :path,       :string, :limit => 255
            t.column :name,       :string, :limit => 30, :null => false
        end
        add_index :project_sections,   :parent_id
        add_index :project_sections,   :lft
        add_index :project_sections,   :rgt
        add_index :project_sections,   :identifier
        add_index :project_sections, [ :parent_id, :identifier ], :unique => true
        add_index :project_sections,   :path
    end

    def self.down
        drop_table :project_sections
    end

end
