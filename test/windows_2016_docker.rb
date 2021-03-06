describe 'windows_2016_docker' do
  describe command('& docker version') do
    its(:stdout) { should match /Client:. Version:      1.12.2-cs2-ws-beta. API version:  1.25/m }
    its(:stdout) { should match /Server:. Version:      1.12.2-cs2-ws-beta. API version:  1.25/m }
    its(:exit_status) { should eq 0 }
  end

  describe 'Docker service' do
    describe service('docker') do
      it { should be_installed  }
      it { should be_enabled  }
      it { should be_running  }
      it { should have_start_mode("Automatic")  }
    end
    describe port(2375) do
      it { should be_listening  }
    end
  end

  describe 'Docker images' do
    describe docker_image('microsoft/windowsservercore:latest') do
      it { should exist }
    end
    describe docker_image('microsoft/windowsservercore:10.0.14393.321') do
      it { should exist }
    end
    describe docker_image('microsoft/nanoserver:latest') do
      it { should exist }
    end
    describe docker_image('microsoft/nanoserver:10.0.14393.321') do
      it { should exist }
    end
  end
end
