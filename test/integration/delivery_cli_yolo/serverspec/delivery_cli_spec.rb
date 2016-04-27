require 'spec_helper'

describe 'test::delivery_cli_yolo' do
  describe package('delivery-cli') do
    it { should be_installed }
  end
end
