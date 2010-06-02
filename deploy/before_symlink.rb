run "cd #{release_path} && bundle install"
run "cd #{release_path} && bundle lock"
run "ln -s #{shared_path}/config/oauth2.yml #{release_path}/config/"
