#
# Cookbook:: chef-ingredient
# Spec:: chef_file
#
# Copyright 2016 Chef Software Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe 'test::file' do
  cached(:centos_7) do
    ChefSpec::ServerRunner.new(
      step_into: 'chef_file',
      platform: 'centos',
      version: '7.3.1611'
    ).converge(described_recipe)
  end

  context 'compiling the recipe' do
    it 'creates chef_file[/tmp/uri.test]' do
      expect(centos_7).to create_chef_file('/tmp/remote_file')
    end
    it 'creates chef_file[/tmp/cookbook.test]' do
      expect(centos_7).to create_chef_file('/tmp/cookbook_file')
    end
    it 'creates chef_file[/tmp/content.test]' do
      expect(centos_7).to create_chef_file('/tmp/file')
    end
  end

  context 'stepping into chef_file' do
    it 'correctly creates cookbook_files' do
      expect(centos_7).to create_cookbook_file('/tmp/cookbook_file')
        .with(
          source: 'testfile',
          cookbook: 'chef_test',
          user: 'root',
          group: 'root',
          mode: '0600'
        )
    end
    it 'correctly creates remote_files' do
      expect(centos_7).to create_remote_file('/tmp/remote_file')
        .with(
          source: 'https://www.example.com/test',
          user: 'root',
          group: 'root',
          mode: '0600'
        )
    end
    it 'correctly creates files' do
      expect(centos_7).to create_file('/tmp/file')
        .with(
          content: 'abcdef',
          user: 'root',
          group: 'root',
          mode: '0600'
        )
      expect(centos_7).to render_file('/tmp/file').with_content('abcdef')
    end
  end
end
