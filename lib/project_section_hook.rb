class ProjectSectionHook  < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('admin', :plugin => 'project_section')
    end

    render_on :view_projects_form, :partial => 'projects/section'

end
