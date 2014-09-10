# chef-server-ingredient Cookbook

This cookbook is used by CHEF in Hosted Chef to manage Chef Server and Chef Server add-on component installation and reconfiguration. It provides no useful recipes. Instead, wrapper cookbooks should be created using the resource that this cookbook contains.

As of initial release, the cookbook borrows from, but does not use [Packagecloud's](http://packagecloud.io) cookbook to set up the repository where we publish Chef Server packages.

## Requirements

### Platform:

- Ubuntu 14.04

### Cookbooks:

- apt

## License and Author

- Author: Joshua Timberman
- Copyright (C) 2014, Chef Software Inc. <legal@getchef.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
