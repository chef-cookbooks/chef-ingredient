#
# Author:: Salim Afiune <afiune@chef.io>
# Copyright (c) 2015, Chef Software, Inc. <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['chef-ingredient'] = {}

# Set `custom-repo-recipe` to a string "cookbook::recipe" to specify
# a custom recipe that sets up your own yum/apt repository where you have
# mirrored the ingredient packages you want to use.
#
# Do this elsewhere in your cookbook where you use chef_ingredient, in a
# policyfile, environment, role, etc.
#
# default['chef-ingredient']['custom-repo-recipe'] = 'custom_repo::awesome_custom_setup'

# Testing Attributes #
#
# Optionally install the mixlib-install gem from source. This ref can be
# a revision, branch or tag.
#
default['chef-ingredient']['mixlib-install']['git_ref'] = nil
