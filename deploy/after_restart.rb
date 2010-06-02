require 'tmpdir'

run "rm -rf #{Dir.tmpdir}/smeagol"
run "mkdir -p #{release_path}/public"
run "curl -X POST http://ciderapp.org/refresh -d ''"
