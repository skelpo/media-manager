# MediaManager

MediaManager is a micro-service written in Vapor, a server-side Swift framework. It works as an interface for media storage APIs such as Amazon S3 and Google Cloud Storage.

**Note:**  MediaManager has Amazon S3 implemented by default. This can be removed if desired.

## Setup

After forking and cloning the repo, you can configure the various services used for storing resources. MediaManager already has Amazon S3 configured, so you can follow it, but here is an outline of what you need to do:

1. Install the storage client package for the service you wish to use. A list of available services can be found [here](#storage-services).
2. For cleanness sake, create a new file in the `Sources/App/Configuration` directory for the service you are using.
3. Add a function to your new file that will take in an `inout Services` and `StorageControllerCache` instances.
4. In the function you create, register the required services used by the storage service. Then add the storage service itself to the cache:

   ```swift
   cache.register(storage: Storage.self, slug: "storage")
   ```
   
   Note: The slug value will be used to construct a controller's routes.

5. In the `configuration.swift` file, add a call to your function, passing in the `Services` and `StorageControllerCache` instance.

   ```swift
   let cache = StorageControllerCache()
   try storage(&services, cache: cache) // <== Add line
    
   services.register(cache)
   ```
   
That's it! The storage service is now available through the MediaManager API.

## Storage Services

- [Amazon S3](https://github.com/skelpo/S3Storage)
- [Google Cloud Storage](https://github.com/skelpo/GoogleCloudStorage)
- The local file system comes by default.

## API

The routes for the MediaManager are all under the `/*/media-manager` path. Each service is registered under the slug that it configured with, `/*/media-manager/s3` for example.

Each service has 4 routes:

- `POST /*/media-manager/<slug>/`
	
	Stores the new file under the service in the URL.
	
	| Parameter  |                  Description                 |
	|------------|----------------------------------------------|
	| `filename` | The relative directory and name for the file |
	| `data`	   | The contents of the file                     |
	

- `GET /*/media-manager/<slug>/...`

	Fetches the contents of a file under the given directory and filename in the 
	URL suffix.

- `PUT /*/media-manager/<slug>/...`

	Replaces the contents of a file under the given directory and filename in 
	the URL suffix.
	
	| Parameter |          Description          |
	|-----------|-------------------------------|
	| `data`    | The new contents of the file  |

- `DELETE /*/media-manager/<slug>/...`

	Deletes the file 



## LICENSE

The MediaManager service is under the [MIT license agreement](https://github.com/skelpo/media-manager/blob/master/LICENSE).