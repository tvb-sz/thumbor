# thumbor

latest thumbor docker image base on alpine

## config thumbor

### Method 1: Use the complete configuration

Copy and fill your full config file to path: `/usr/local/thumbor/thumbor.conf`

### Method 2: Use configuration templates and environment variable files

Copy and fill your config template file and .env file to path: `/usr/local/thumbor/thumbor.conf.tpl` and `/app/.env`

for `/usr/local/thumbor/thumbor.conf.tpl`
````
# make config template file
thumbor-config > thumbor.conf.tpl

# then edit it
````

for `/app/.env`
````
# just key/value pairs
# for example
RESULT_STORAGE = 'thumbor_gcs.result_storage.gcs_result_storage'
WATER_IMAGE_LOCAL_PATH="/data"
````
