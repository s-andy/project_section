class ProjectSectionHook  < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
        stylesheets = stylesheet_link_tag('sections', :plugin => 'project_section')
        if File.exists?(File.join(File.dirname(__FILE__), "../assets/stylesheets/#{Setting.ui_theme}.css"))
            stylesheets << stylesheet_link_tag(Setting.ui_theme, :plugin => 'project_section')
        end
        stylesheets
    end

    render_on :view_projects_form,                           :partial => 'projects/section'
    render_on :view_custom_fields_form_issue_custom_field,   :partial => 'custom_fields/sections'
    render_on :view_custom_fields_form_project_custom_field, :partial => 'custom_fields/sections'
    render_on :view_custom_fields_form_version_custom_field, :partial => 'custom_fields/sections'

end
