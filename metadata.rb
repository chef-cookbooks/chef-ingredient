name             'chef-server-ingredient'
maintainer       'Joshua Timberman'
maintainer_email 'cookbooks@getchef.com'
license          'Apache 2.0'
description      'Manages Chef Server packages/add-ons, aka "ingredients"'
version          '0.0.2'
# we'd rather use packagecloud, but we aren't supporting non-debian
# family systems just yet, and packagecloud_repo uses
# node['lsb']['codename'].
depends          'apt'
depends          'packagecloud'
