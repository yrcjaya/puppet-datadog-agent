require 'spec_helper'

describe 'datadog_agent::reports' do
  context 'all supported operating systems' do
    let(:params) do
      {
        api_key: 'notanapikey',
        hostname_extraction_regex: nil,
        puppetmaster_user: 'puppet',
        dogapi_version: 'installed',
        puppet_gem_provider: 'gem'
      }
    end
    ALL_OS.each do |operatingsystem|
      describe "datadog_agent class common actions on #{operatingsystem}" do
        let(:facts) do
          {
            operatingsystem: operatingsystem,
            osfamily: DEBIAN_OS.include?(operatingsystem) ? 'debian' : 'redhat'
          }
        end

        it { should contain_class('ruby').with_rubygems_update(false) }
        it { should contain_class('ruby::params') }
        it { should contain_package('ruby').with_ensure('installed') }
        it { should contain_package('rubygems').with_ensure('installed') }

        if DEBIAN_OS.include?(operatingsystem)
          it do
            should contain_package('ruby-dev')\
              .with_ensure('installed')\
              .that_comes_before('Package[dogapi]')
          end
        elsif REDHAT_OS.include?(operatingsystem)
          it do
            should contain_package('ruby-devel')\
              .with_ensure('installed')\
              .that_comes_before('Package[dogapi]')
          end
        end

        it do
          should contain_package('dogapi')\
            .with_ensure('installed')
            .with_provider('gem')
        end

        it do
          should contain_file('/etc/dd-agent/datadog.yaml')\
            .with_owner('puppet')\
            .with_group('root')
        end

      end
    end
  end
  context 'specific dogapi version' do
    let(:params) do
      {
        api_key: 'notanapikey',
        hostname_extraction_regex: nil,
        puppetmaster_user: 'puppet',
        dogapi_version: '1.2.2',
        puppet_gem_provider: 'gem'
      }
    end
    describe "datadog_agent class dogapi version override" do
      let(:facts) do
        {
          operatingsystem: 'Debian',
          osfamily: 'debian'
        }
      end

      it { should contain_class('ruby').with_rubygems_update(false) }
      it { should contain_class('ruby::params') }
      it { should contain_package('ruby').with_ensure('installed') }
      it { should contain_package('rubygems').with_ensure('installed') }

      it do
        should contain_package('ruby-dev')\
          .with_ensure('installed')\
          .that_comes_before('Package[dogapi]')
      end

      it do
        should contain_package('dogapi')\
          .with_ensure('1.2.2')
          .with_provider('gem')
      end

      it do
        should contain_file('/etc/dd-agent/datadog.yaml')\
          .with_owner('puppet')\
          .with_group('root')
      end
    end
  end
end
