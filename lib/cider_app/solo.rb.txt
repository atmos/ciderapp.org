#
# Chef Solo Config File
#

cider_root      = File.expand_path("~/.cider")

log_level       :info
log_location    STDOUT

recipe_url      "http://ciderapp.org/cider.tgz"
json_attribs    "http://ciderapp.org/latest"

sandbox_path     "#{cider_root}/sandboxes"
cookbook_path    "#{cider_root}/cookbooks"
file_cache_path  "#{cider_root}"
file_backup_path "#{cider_root}/backup"
cache_options   ({ :path => "#{cider_root}/cache/checksums", :skip_expires => true })
