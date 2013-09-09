if Rails::VERSION::MAJOR < 3

    ActionController::Routing::Routes.draw do |map|
        map.connect('sections',            :controller => 'project_sections', :action => 'index')
        map.connect('sections/new',        :controller => 'project_sections', :action => 'new')
        map.connect('sections/create',     :controller => 'project_sections', :action => 'create',  :conditions => { :method => :post })
        map.connect('sections/:id/edit',   :controller => 'project_sections', :action => 'edit')
        map.connect('sections/:id/update', :controller => 'project_sections', :action => 'update',  :conditions => { :method => :put })
        map.connect('sections/:id',        :controller => 'project_sections', :action => 'destroy', :conditions => { :method => :delete })
        map.connect('section/*section',    :controller => 'sections',         :action => 'index')
        map.connect('project/*section',    :controller => 'projects',         :action => 'show')
    end

else

    match('sections',          :to => 'project_sections#index')
    match('sections/new',      :to => 'project_sections#new')
    post('sections/create',    :to => 'project_sections#create')
    match('sections/:id/edit', :to => 'project_sections#edit')
    put('sections/:id/update', :to => 'project_sections#update')
    delete('sections/:id',     :to => 'project_sections#destroy')
    match('section/*section',  :to => 'sections#index')
    match('project/*section',  :to => 'projects#show')

end
