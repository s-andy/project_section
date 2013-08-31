require_dependency 'redmine/menu_manager'

module SectionMenuHelperPatch

    def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            alias_method_chain :render_single_menu_node, :sections
        end
    end

    module InstanceMethods

        def render_single_menu_node_with_sections(item, caption, url, selected)
            if item.name == :overview && url[:controller] == 'projects' && url[:action] == 'show'
                begin
                    project = Project.find(url[:id])
                    link_to(h(caption), sectioned_project_url(project, url), item.html_options(:selected => selected))
                rescue ActiveRecord::RecordNotFound
                    render_single_menu_node_without_sections(item, caption, url, selected)
                end
            else
                render_single_menu_node_without_sections(item, caption, url, selected)
            end
        end

    end

end
