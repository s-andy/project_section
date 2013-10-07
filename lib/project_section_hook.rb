class ProjectSectionHook  < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context = {})
        stylesheets = stylesheet_link_tag('admin', :plugin => 'project_section') # FIXME rename
        if File.exists?(File.join(File.dirname(__FILE__), "../assets/stylesheets/#{Setting.ui_theme}.css"))
            stylesheets << stylesheet_link_tag(Setting.ui_theme, :plugin => 'project_section')
        end
        stylesheets
    end

    render_on :view_projects_form, :partial => 'projects/section'

end
