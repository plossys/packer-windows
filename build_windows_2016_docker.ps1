packer build --only=vmware-iso `
  --var autounattend=./tmp/2016/Autounattend.xml `
  windows_2016_docker_vcloud.json
#  --var iso_url=./iso/en_windows_server_2016_x64_dvd_9327751.iso `
#  --var iso_checksum=91d7b2ebcff099b3557570af7a8a5cd6 `
