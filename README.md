# thumbor for docker

latest thumbor docker image base on alpine

* source file at: [https://github.com/tvb-sz/thumbor](https://github.com/tvb-sz/thumbor)
* docker image at: [https://hub.docker.com/r/nmgsz/thumbor](https://hub.docker.com/r/nmgsz/thumbor)

## config thumbor

### Method 1: Use the complete configuration

Copy and fill your full config file to path: `/app/thumbor.conf`

### Method 2: Use configuration templates and environment variable files

Copy and fill your config template file and .env file to path: `/app/thumbor.conf.tpl` and `/app/.env`

for `/app/thumbor.conf.tpl`
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
## Volume mapping

````
/data:/data
````

## Healthcheck

because docker file use command `HEALTHCHECK`, handler `thumbor.handler_lists.healthcheck` need enable.
````diff
HANDLER_LISTS = [
    +'thumbor.handler_lists.healthcheck',
]
````


* can use env `THUMBOR_PORT` change port when run docker container
* can use path `/data` as your local disk volume

## serve `favicon.ico`

use [thumbor-icon-handler](https://github.com/jjonline/thumbor-icon-handler)

config `HANDLER_LISTS` add `thumbor_icon_handler.icon`
````diff
HANDLER_LISTS = [
    'thumbor.handler_lists.healthcheck',
    'thumbor.handler_lists.upload',
    'thumbor.handler_lists.blacklist',
    +'thumbor_icon_handler.icon',
]
````

## use aws-s3 as STORAGE, LOADER or RESULT_STORAGE

> More information [https://github.com/thumbor/thumbor-aws](https://github.com/thumbor/thumbor-aws)

config `LOADER` , `STORAGE` , `RESULT_STORAGE`
````
## The loader thumbor should use to find source images.
## This must be the full name of a python module (python must be able to import it)
LOADER = "thumbor.loaders.http_loader"

## The file storage thumbor should use to store original images.
## This must be the full name of a python module (python must be able to import it)
STORAGE = 'thumbor_aws.storage'

## The result storage thumbor should use to store generated images.
## This must be the full name of a python module (python must be able to import it)
RESULT_STORAGE = 'thumbor_aws.result_storage'
````

config aws-s3
````
################################### AWS ########################################
# More information https://github.com/thumbor/thumbor-aws
################################## AWS Loader ##################################

## Region where thumbor's objects are going to be loaded from.
## Defaults to: 'us-east-1'
{% if AWS_LOADER_REGION_NAME is defined %}
AWS_LOADER_REGION_NAME = '{{ AWS_LOADER_REGION_NAME }}'
{% endif %}

## S3 Bucket where thumbor's objects are loaded from.
## Defaults to: 'thumbor'
{% if AWS_LOADER_BUCKET_NAME is defined %}
AWS_LOADER_BUCKET_NAME = '{{ AWS_LOADER_BUCKET_NAME }}'
{% endif %}

## Secret access key for S3 Loader.
## Defaults to: None
{% if AWS_LOADER_S3_SECRET_ACCESS_KEY is defined %}
AWS_LOADER_S3_SECRET_ACCESS_KEY = '{{ AWS_LOADER_S3_SECRET_ACCESS_KEY }}'
{% endif %}

## Access key ID for S3 Loader.
## Defaults to: None
{% if AWS_LOADER_S3_ACCESS_KEY_ID is defined %}
AWS_LOADER_S3_ACCESS_KEY_ID = '{{ AWS_LOADER_S3_ACCESS_KEY_ID }}'
{% endif %}

## Endpoint URL for S3 API. Very useful for testing.
## Defaults to: None
{% if AWS_LOADER_S3_ENDPOINT_URL is defined %}
AWS_LOADER_S3_ENDPOINT_URL = '{{ AWS_LOADER_S3_ENDPOINT_URL }}'
{% endif %}

## Loader prefix path.
## Defaults to: ''
AWS_LOADER_ROOT_PATH = '{{ AWS_LOADER_ROOT_PATH | default('') }}'

################################################################################


################################# AWS Storage ##################################
# Documentation: https://github.com/thumbor/thumbor-aws#storage

## Region where thumbor's objects are going to be stored.
## Defaults to: 'us-east-1'
AWS_STORAGE_REGION_NAME = '{{ AWS_STORAGE_REGION_NAME | default('us-east-1') }}'

## S3 Bucket where thumbor's objects are going to be stored.
## Defaults to: 'thumbor'
AWS_STORAGE_BUCKET_NAME = '{{ AWS_STORAGE_BUCKET_NAME | default('thumbor') }}'

## Secret access key for S3 to allow thumbor to store objects there.
## Defaults to: None
{% if AWS_STORAGE_S3_SECRET_ACCESS_KEY is defined %}
AWS_STORAGE_S3_SECRET_ACCESS_KEY = '{{ AWS_STORAGE_S3_SECRET_ACCESS_KEY }}'
{% else %}
AWS_STORAGE_S3_SECRET_ACCESS_KEY = None
{% endif %}

## Access key ID for S3 to allow thumbor to store objects there.
## Defaults to: None
{% if AWS_STORAGE_S3_ACCESS_KEY_ID is defined %}
AWS_STORAGE_S3_ACCESS_KEY_ID = '{{ AWS_STORAGE_S3_ACCESS_KEY_ID }}'
{% else %}
AWS_STORAGE_S3_ACCESS_KEY_ID = None
{% endif %}

## Endpoint URL for S3 API. Very useful for testing.
## Defaults to: None
{% if AWS_STORAGE_S3_ENDPOINT_URL is defined %}
AWS_STORAGE_S3_ENDPOINT_URL = '{{ AWS_STORAGE_S3_ENDPOINT_URL }}'
{% else %}
AWS_STORAGE_S3_ENDPOINT_URL = None
{% endif %}

## Storage prefix path.
## Defaults to: ''
AWS_STORAGE_ROOT_PATH = '{{ AWS_STORAGE_ROOT_PATH | default('') }}'

## Storage ACL for files written in bucket
## Defaults to: 'public-read'
{% if AWS_STORAGE_S3_ACL is defined %}
AWS_STORAGE_S3_ACL = '{{ AWS_STORAGE_S3_ACL }}'
{% endif %}

## Default location to use if S3 does not return location header. Can use
## {bucket_name} var.
## Defaults to: 'https://{bucket_name}.s3.amazonaws.com'
{% if AWS_DEFAULT_LOCATION is defined %}
AWS_DEFAULT_LOCATION = '{{ AWS_DEFAULT_LOCATION }}'
{% endif %}

################################################################################


############################## AWS Result Storage ##############################
# Documentation: https://github.com/thumbor/thumbor-aws#result-storage

## Region where thumbor's objects are going to be stored.
## Defaults to: 'us-east-1'
{% if AWS_RESULT_STORAGE_REGION_NAME is defined %}
AWS_RESULT_STORAGE_REGION_NAME = '{{ AWS_RESULT_STORAGE_REGION_NAME }}'
{% endif %}

## S3 Bucket where thumbor's objects are going to be stored.
## Defaults to: 'thumbor'
{% if AWS_RESULT_STORAGE_BUCKET_NAME is defined %}
AWS_RESULT_STORAGE_BUCKET_NAME = '{{ AWS_RESULT_STORAGE_BUCKET_NAME }}'
{% endif %}

## Secret access key for S3 to allow thumbor to store objects there.
## Defaults to: None
{% if AWS_RESULT_STORAGE_S3_SECRET_ACCESS_KEY is defined %}
AWS_RESULT_STORAGE_S3_SECRET_ACCESS_KEY = '{{ AWS_RESULT_STORAGE_S3_SECRET_ACCESS_KEY }}'
{% endif %}

## Access key ID for S3 to allow thumbor to store objects there.
## Defaults to: None
{% if AWS_RESULT_STORAGE_S3_ACCESS_KEY_ID is defined %}
AWS_RESULT_STORAGE_S3_ACCESS_KEY_ID = '{{ AWS_RESULT_STORAGE_S3_ACCESS_KEY_ID }}'
{% endif %}

## Endpoint URL for S3 API. Very useful for testing.
## Defaults to: None
{% if AWS_RESULT_STORAGE_S3_ENDPOINT_URL is defined %}
AWS_RESULT_STORAGE_S3_ENDPOINT_URL = '{{ AWS_RESULT_STORAGE_S3_ENDPOINT_URL }}'
{% endif %}

## Result Storage prefix path.
## Defaults to: ''
AWS_RESULT_STORAGE_ROOT_PATH = '{{ AWS_RESULT_STORAGE_ROOT_PATH | default('') }}'

## ACL to use for storing items in S3.
## Defaults to: None
{% if AWS_RESULT_STORAGE_S3_ACL is defined %}
AWS_RESULT_STORAGE_S3_ACL = '{{ AWS_RESULT_STORAGE_S3_ACL }}'
{% endif %}
````

## use google-cloud-storage as STORAGE, LOADER or RESULT_STORAGE

> More information [https://github.com/jjonline/thumbor-gcs](https://github.com/jjonline/thumbor-gcs)


config `LOADER` , `RESULT_STORAGE`
````
## The loader thumbor should use to find source images.
## This must be the full name of a python module (python must be able to import it)
LOADER = "thumbor_gcs.loader.gcs_loader"

## The result storage thumbor should use to store generated images.
## This must be the full name of a python module (python must be able to import it)
RESULT_STORAGE = 'thumbor_gcs.result_storage.gcs_result_storage'
````
