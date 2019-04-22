#!/bin/sh

work_dir=$PWD
the_env=$1

if [ $the_env == "develop" ]
then
  cp .env.develop .env
else
  cp .env.production .env
fi

cd ios
fastlane ios release --env=$the_env

cd ../android
fastlane android release --env=$the_env

echo "android: ${work_dir}/build/app/outputs/apk/release/app-release.apk"
echo "ios: ${work_dir}/ios/release/${the_env}.ipa"
