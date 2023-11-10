# Device Sync Bundle Realm Playground

## Testing Device Sync Bundle Realm

* Fill in your `APPID`, change the sample Model to your data schema and customise the flexible sync subscription you are using to retrieve your data.
* Run `swift run` in the root of `CommandCreate`, this will creates the bundle realm used in the sample project.
* Run the project in `SupportHELPFlexibleSync` which tests opening the realm with the bundle realm and then sync any data from the new subscriptions or 
  data that is not in the bundle realm

## Notes

* Bundle Realms have an expiration time that correspond to the `Refresh Token Expiration` in Atlas Device Sync UI, so when a Realm is bundle and the 
  expiration time has passed this will trigger a Client reset, which will end up doing an initial download of all the data. 
  Having in mind this, a bundle realm should be create the day of the release and have a long expiration time.
