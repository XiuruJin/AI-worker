#!/bin/bash
# get cli params
username=$1
password=$2
horde_url=$3
api_key=$4
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ];then
    echo "please input all params"
    echo "\$1: username"
    echo "\$2: password"
    echo "\$3: horde_url"
    echo "\$4: api_key"
    exit 0
fi

host_name=`hostname`
# process cuda
# sed -i 's/cuda117/${cuda_version}/g' requirements.txt

echo "set bridge data"
if [ ! -f bridgeData.py ];then
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
    echo $horde_url
    sed -i  "s#^horde_url.*#horde_url = \"${horde_url}\"#g" bridgeData.py
    sed -i  "s#^api_key.*#api_key = \"${api_key}\"#g" bridgeData.py
    sed -i "s#^worker_name.*#worker_name = \"${worker_name}\"#g" bridgeData.py
fi

# creds.py
echo "set creds..."
if [ ! -f creds.py ];then
echo ">>>"
cat << EOF > creds.py
hf_username = "${username}"
hf_password = "${password}"
EOF
else
    echo "----"
    echo $username
    sed -i "s#^hf_username.*#hf_username = \"${username}\"#g" creds.py
    sed -i "s#^hf_password.*#hf_password = \"${password}\"#g" creds.py
fi
echo "start update runtime..."
sh update_runtime.sh
echo "start worker"
sh horde_bridge.sh
