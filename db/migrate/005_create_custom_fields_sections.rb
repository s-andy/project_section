class CreateCustomFieldsSections < ActiveRecord::Migration

    def self.up
        create_table :custom_fields_sections, :id => false do |t|
            t.column :custom_field_id, :integer, :null => false
            t.column :section_id,      :integer, :null => false
        end
        add_index :custom_fields_sections, [ :custom_field_id, :section_id ], :unique => true
    end

    def self.down
        drop_table :custom_fields_sections
    end

end
