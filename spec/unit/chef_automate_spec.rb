#
# Cookbook:: chef-ingredient
# Spec:: chef_automate
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

insecure_key = <<-EOS
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzI
w+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoP
kcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2
hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NO
Td0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcW
yLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQIBIwKCAQEA4iqWPJXtzZA68mKd
ELs4jJsdyky+ewdZeNds5tjcnHU5zUYE25K+ffJED9qUWICcLZDc81TGWjHyAqD1
Bw7XpgUwFgeUJwUlzQurAv+/ySnxiwuaGJfhFM1CaQHzfXphgVml+fZUvnJUTvzf
TK2Lg6EdbUE9TarUlBf/xPfuEhMSlIE5keb/Zz3/LUlRg8yDqz5w+QWVJ4utnKnK
iqwZN0mwpwU7YSyJhlT4YV1F3n4YjLswM5wJs2oqm0jssQu/BT0tyEXNDYBLEF4A
sClaWuSJ2kjq7KhrrYXzagqhnSei9ODYFShJu8UWVec3Ihb5ZXlzO6vdNQ1J9Xsf
4m+2ywKBgQD6qFxx/Rv9CNN96l/4rb14HKirC2o/orApiHmHDsURs5rUKDx0f9iP
cXN7S1uePXuJRK/5hsubaOCx3Owd2u9gD6Oq0CsMkE4CUSiJcYrMANtx54cGH7Rk
EjFZxK8xAv1ldELEyxrFqkbE4BKd8QOt414qjvTGyAK+OLD3M2QdCQKBgQDtx8pN
CAxR7yhHbIWT1AH66+XWN8bXq7l3RO/ukeaci98JfkbkxURZhtxV/HHuvUhnPLdX
3TwygPBYZFNo4pzVEhzWoTtnEtrFueKxyc3+LjZpuo+mBlQ6ORtfgkr9gBVphXZG
YEzkCD3lVdl8L4cw9BVpKrJCs1c5taGjDgdInQKBgHm/fVvv96bJxc9x1tffXAcj
3OVdUN0UgXNCSaf/3A/phbeBQe9xS+3mpc4r6qvx+iy69mNBeNZ0xOitIjpjBo2+
dBEjSBwLk5q5tJqHmy/jKMJL4n9ROlx93XS+njxgibTvU6Fp9w+NOFD/HvxB3Tcz
6+jJF85D5BNAG3DBMKBjAoGBAOAxZvgsKN+JuENXsST7F89Tck2iTcQIT8g5rwWC
P9Vt74yboe2kDT531w8+egz7nAmRBKNM751U/95P9t88EDacDI/Z2OwnuFQHCPDF
llYOUI+SpLJ6/vURRbHSnnn8a/XG+nzedGH5JGqEJNQsz+xT2axM0/W/CRknmGaJ
kda/AoGANWrLCz708y7VYgAtW2Uf1DPOIYMdvo6fxIB5i9ZfISgcJ/bbCUkFrhoH
+vq/5CIWxCPp0f85R4qxxQ5ihxJ0YDQT9Jpx4TMss4PSavPaBH3RXow5Ohe+bYoQ
NE5OgEXk2wVfZczCZpigBKbKZHNYcelXtTt/nP3rsCuGcM4h53s=
-----END RSA PRIVATE KEY-----
EOS

require 'spec_helper'

describe 'test::automate' do
  cached(:centos_7) do
    stub_command('automate-ctl list-enterprises --ssh-pub-key-file=/etc/delivery/builder_key.pub | grep -w test').and_return(false)
    stub_command('automate-ctl status').and_return(true)
    ChefSpec::ServerRunner.new(
      step_into: 'chef_automate',
      platform: 'centos',
      version: '7.3.1611'
    ).converge(described_recipe)
  end

  context 'compiling the recipe' do
    it 'creates chef_automate[automate.chefstack.local]' do
      expect(centos_7).to create_chef_automate('automate.chefstack.local')
    end
  end

  context 'stepping into chef_automate' do
    it 'upgrades chef_ingredient[automate]' do
      expect(centos_7).to upgrade_chef_ingredient('automate')
        .with(
          channel: :current,
          version: '0.6.64',
          accept_license: true,
          enterprise: ['test'],
          license: 'license',
          chef_user: 'chef_user',
          chef_user_pem: insecure_key,
          validation_pem: insecure_key,
          builder_pem: insecure_key
        )
    end

    it 'creates required directories' do
      [
        '/var/opt/delivery/license',
        '/etc/delivery',
        '/etc/chef',
      ].each do |dir|
        expect(centos_7).to create_directory(dir)
      end
    end

    it 'creates automate keys' do
      expect(centos_7).to create_chef_file('/var/opt/delivery/license/delivery.license')
        .with(
          source: 'license',
          user: 'delivery',
          group: 'delivery',
          mode: '0644'
        )
      {
        '/etc/delivery/chef_user.pem' => insecure_key,
        '/etc/chef/validation.pem' => insecure_key,
      }.each do |file, src|
        expect(centos_7).to create_chef_file(file)
          .with(
            source: src,
            user: 'root',
            group: 'root',
            mode: '0644'
          )
      end
      expect(centos_7).to create_chef_file('/etc/delivery/builder_key')
        .with(
          source: insecure_key,
          user: 'root',
          group: 'root',
          mode: '0600'
        )
    end

    it 'creates the builder public key' do
      expect(centos_7).to create_file('/etc/delivery/builder_key.pub')
        .with(
          user: 'root',
          group: 'root',
          mode: '0644'
        )
    end

    it 'configures nginx to host installation files' do
      expect(centos_7).to create_directory('/var/opt/delivery/nginx/etc/addon.d')
      expect(centos_7).to create_file('/var/opt/delivery/nginx/etc/addon.d/99-installer_internal.conf')
        .with(
          content: <<-EOF
location /installer {
  alias /opt/delivery/embedded/service/omnibus-ctl/installer;
}
EOF
        )
    end

    it 'reconfigures automate' do
      expect(centos_7).to render_ingredient_config('automate')
      expect(centos_7.ingredient_config('automate')).to notify('chef_ingredient[automate]').to(:reconfigure).immediately
    end

    it 'configures automate enterprises' do
      expect(centos_7).to run_execute('create enterprise test')
    end
  end
end
