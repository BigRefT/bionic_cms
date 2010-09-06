# Undefined unneeded tasks in instance mode
unless Bionic.app?
  def undefine_task(*names)
    app = Rake.application
    tasks = app.instance_variable_get('@tasks')
    names.flatten.each { |name| tasks.delete(name) }
  end
  
  undefine_task %w(
    bionic:clobber_package 
    bionic:install_gem
    bionic:package
    bionic:release
    bionic:repackage
    bionic:uninstall_gem
    bionic:gem
    bionic:gem:install
    bionic:gem:uninstall
    rails:freeze:edge
    rails:freeze:gems
    rails:unfreeze
    rails:update
    rails:update:application_controller
    rails:update:configs
    rails:update:javascripts
    rails:update:scripts
  )
end