#!/bin/bash

#install kata
source /etc/os-release

ARCH=$(arch)
BRANCH="1.8.0"

isRedHat=""
if [[ -f /etc/os-release ]] ; then
    isRedHat=$( cat /etc/os-release | grep "Red Hat"  )
    if [[ $isRedHat != "" ]] ; then
      VERSION_ID=7
    fi
fi
#echo $VERSION_ID

dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`

if [ "$dist" == "Ubuntu" ]; then
  sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/${BRANCH}/xUbuntu_$(lsb_release -rs)/ /' > /etc/apt/sources.list.d/kata-containers.list"
  curl -sL  http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/${BRANCH}/xUbuntu_$(lsb_release -rs)/Release.key | sudo apt-key add -
  sudo -E apt-get update
  sudo -E apt-get -y install kata-runtime kata-proxy kata-shim
else
   yum -y install yum-utils
   sudo -E yum-config-manager --add-repo "http://download.opensuse.org/repositories/home:/katacontainers:/releases:/${ARCH}:/${BRANCH}/CentOS_${VERSION_ID}/home:katacontainers:releases:${ARCH}:${BRANCH}.repo"
   sudo -E yum -y install kata-runtime kata-proxy kata-shim
fi

crioconf="/etc/crio/crio.conf"
kataconf="/usr/share/defaults/kata-containers/configuration.toml"

if (grep  "/usr/bin/kata-runtime" $crioconf> /dev/null); then
    echo "kata configuration already exist!!"
else {
    echo "configuring kata-runtime "
    
    sed -i '/path/ s/qemu-vanilla-system-x86_64/qemu-vanilla-system-ppc64/' $kataconf
    sed -i -e 's$image = "/usr/share/kata-containers/kata-containers.img"$initrd = "/usr/share/kata-containers/kata-containers-initrd.img"$g' $kataconf
    
    {
        echo
        echo '[crio.runtime.runtimes.kata]'
        echo 'runtime_path = "/usr/bin/kata-runtime"'
        echo
    } >> $crioconf
    sed -i '/manage_network_ns_lifecycle/ s/false/true/' $crioconf
    ppc64_cpu --smt=off
    systemctl daemon-reload
    systemctl restart crio
}
fi


