#packer build --only=vmware-iso `
#  --var iso_url=./iso/en_windows_10_enterprise_version_1607_updated_jul_2016_x64_dvd_9054264.iso `
#  --var iso_checksum=F9FFEA3A40BF39CCDE105BB064E153343560D73E `
#  --var autounattend=./tmp/10/Autounattend.xml `
#  windows_10_vcloud.json

packer build --only=vmware-iso `
  --var iso_url=C:\Users\stefan.scherer\packer_cache\15031.0.170204-1546.RS2_RELEASE_CLIENTPRO-CORE_OEMRET_X64FRE_EN-US.ISO `
  --var iso_checksum=d35a1bc67c4cf0226a4e7381752e81a0ab081356 `
  --var autounattend=C:\Users\stefan.scherer\Dropbox\packer-windows\answer_files\10_pro_msdn\Autounattend.xml `
  --var vm_name=windows_10_15031 `
  windows_10_vcloud.json
