@echo off
set hf_username
set api_key
set hf_password
set horde_url

if not {%1} == {} (
	echo %1
) else ( 
	echo "param username not found" 
	echo "please input these params:"
    echo "param1: username(required)"
    echo "param2: password(required)"
    echo "param3: horde_url(required)"
    echo "param4: api_key(required)"
    echo "param5: if update requirements(Y/N default N)"
	exit /b 1
)

if not {%2} == {} (
	echo %2
) else ( 
	echo "param password not found" 
	echo "please input these params:"
    echo "param1: username(required)"
    echo "param2: password(required)"
    echo "param3: horde_url(required)"
    echo "param4: api_key(required)"
    echo "param5: if update requirements(Y/N default N)"
	exit /b 1
)

if not {%3} == {} (
	echo %3
	
) else ( 
	echo "param server url not found" 
	echo "please input these params:"
    echo "param1: username(required)"
    echo "param2: password(required)"
    echo "param3: horde_url(required)"
    echo "param4: api_key(required)"
    echo "param5: if update requirements(Y/N default N)"
	exit /b 1
)

if not {%4} == {} (
	echo %4
	
) else ( 
	echo "param api key not found" 
	echo "please input these params:"
    echo "param1: username(required)"
    echo "param2: password(required)"
    echo "param3: horde_url(required)"
    echo "param4: api_key(required)"
    echo "param5: if update requirements(Y/N default N)"
	exit /b 1
)

set hf_username=%1
set hf_password=%2
set horde_url=%3
set api_key=%4
set if_update=%5

if {%if_update%} == {} (
    set if_update=N
)
echo "GPU info >>>"
nvidia-smi --format=csv --query-gpu=name,memory.total,memory.used

if exist bridgeData.py (
	DEL bridgeData.py
)

echo horde_url = "%horde_url%" >> bridgeData.py 
echo worker_name = "%COMPUTERNAME%" >> bridgeData.py 
echo api_key = "%api_key%" >> bridgeData.py 
echo priority_usernames = [] >> bridgeData.py
echo max_power = 8 >> bridgeData.py 
echo queue_size = 1 >> bridgeData.py 
echo max_threads = 3 >> bridgeData.py 
echo nsfw = True >> bridgeData.py 
echo censor_nsfw = False >> bridgeData.py 
echo blacklist = [] >> bridgeData.py 
echo censorlist = [] >> bridgeData.py 
echo allow_img2img = True >> bridgeData.py 
echo allow_painting = True >> bridgeData.py 
echo allow_unsafe_ip = True >> bridgeData.py 
echo allow_post_processing = True >> bridgeData.py 
echo allow_controlnet = False >> bridgeData.py 
echo require_upfront_kudos = False >> bridgeData.py 
echo dynamic_models = True >> bridgeData.py 
echo number_of_dynamic_models = 3 >> bridgeData.py 
echo max_models_to_download = 10 >> bridgeData.py 
echo models_to_load = ['stable_diffusion', 'stable_diffusion_2.1'] >> bridgeData.py 
echo models_to_skip = ['stable_diffusion_inpainting'] >> bridgeData.py 

if exist creds.py (
    DEL creds.py
)

echo hf_username = "%hf_username%" >> creds.py
echo hf_password = "%hf_password%" >> creds.py

if not exist done_cmd.txt (
	echo "start call update-runtime for flag"
	call update-runtime
	echo %ERRORLEVEL%
	if not %ERRORLEVEL% == 0 (
		echo "return error"
		exit  1
	) 
	
	echo "done" > done_cmd.txt
	call horde-bridge
)

if %if_update% == Y (
	echo "start call update-runtime for param Y"
	DEL done_cmd.txt
	call update-runtime
	if not %ERRORLEVEL% == 0 (
		echo "return error"
		exit 1
	) 
	call horde-bridge
	echo "done" > done_cmd.txt
)
