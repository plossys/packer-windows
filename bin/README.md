# bin

Some scripts to be used in basebox-slave Jenkins environment

## build.bat

Run `packer build` for a given template and run the serverspec tests afterwards with Vagrant.
Give the script the name of the template you want to build and test. This
is normally the Jenkins job name.

Jenkins job: Execute Windows batch command:

```cmd
bin\build.bat %JOB_NAME%
```

Manual examples:

```cmd
bin\build.bat windows_2016_vmware
bin\build.bat windows_2016_vcloud
```

## test-box-xxx.bat

These are scripts that are called by the `build.bat` script to run serverspec
tests with Vagrant and the given provider.

Manual examples:

```cmd
bin\test-box-vcloud.bat windows_2016_vcloud
bin\test-box-virtualbox.bat windows_2016_virtualbox
bin\test-box-vmware.bat windows_2016_vmware
```

## upload-vcloud.bat

Upload the vCloud Vagrant box into the vCloud catalog.

```cmd
bin\upload-vclout.bat windows_2016_vcloud
```
