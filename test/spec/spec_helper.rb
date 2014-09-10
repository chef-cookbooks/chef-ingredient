require 'chef/platform'
require 'chef/run_context'
require 'chef/resource'
require 'chef/resource/package'
require 'chef/provider/package'
require 'chef/event_dispatch/base'
require 'chef/event_dispatch/dispatcher'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'libraries'))
