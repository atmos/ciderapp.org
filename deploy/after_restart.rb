require 'tmpdir'
require 'fileutils'

Dir.chdir(Dir.tmpdir) do
  FileUtils.mkdir_p "#{release_path}/public"
  system("git clone git://github.com/atmos/smeagol.git")
  system("tar czvf smeagol #{release_path}/public/cider.tgz")
end
