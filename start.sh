#!/bin/bash
# get cli params
username=$1
password=$2
horde_url=$3
api_key=$4
update_requirements=$5

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ];then
    echo "please input all params"
    echo "\$1: username(required)"
    echo "\$2: password(required)"
    echo "\$3: horde_url(required)"
    echo "\$4: api_key(required)"
    echo "\$5: if update requirements(Y/N default N)"
    exit 0
fi

# print gpu info
echo "GPU info: >>>"
nvidia-smi
if [ $? -ne 0 ];then
    echo "get driver info failed, please check your driver"
    exit 0
fi

host_name=`hostname`
# process cuda
# sed -i 's/cuda117/${cuda_version}/g' requirements.txt

echo "set bridge data"
if [ ! -f bridgeData.py ];then
    echo "create file bridgeData.py"
cat << EOF > bridgeData.py
horde_url = "${horde_url}"
worker_name = "${host_name}"
api_key = "${api_key}"
priority_usernames = []
max_power = 8
queue_size = 1
max_threads = 3
nsfw = True
censor_nsfw = False
blacklist = []
censorlist = []
allow_img2img = True
allow_painting = True
allow_unsafe_ip = True
allow_post_processing = True
allow_controlnet = False
require_upfront_kudos = False
dynamic_models = True
number_of_dynamic_models = 3
max_models_to_download = 10
models_to_load = ['stable_diffusion', 'stable_diffusion_2.1']
models_to_skip = ['stable_diffusion_inpainting']
forms = ['caption', 'nsfw']
EOF
else
    echo "update file bridgeData.py"
    sed -i  "s#^horde_url.*#horde_url = \"${horde_url}\"#g" bridgeData.py
    sed -i  "s#^api_key.*#api_key = \"${api_key}\"#g" bridgeData.py
    sed -i "s#^worker_name.*#worker_name = \"${worker_name}\"#g" bridgeData.py
fi

# creds.py
echo "set creds..."
if [ ! -f creds.py ];then
echo "create file creds.py"
cat << EOF > creds.py
hf_username = "${username}"
hf_password = "${password}"
EOF
else
    echo "update file creds.py"
    sed -i "s#^hf_username.*#hf_username = \"${username}\"#g" creds.py
    sed -i "s#^hf_password.*#hf_password = \"${password}\"#g" creds.py
fi

if [ ! -f .done ] || [ $update_requirements == "Y" ];then
    echo "start update runtime..."
    sh update-runtime.sh
    if [ $? -eq 0 ];then
        rm -f .done
        touch .done
    else
      rm -f .done
      echo "update requirements failed, you can check or retry"
      exit 0
    fi
fi
echo "start worker"
sh horde-bridge.sh


