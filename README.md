[![Build Status](https://secure.travis-ci.org/tulsawebdevs/okletsgo.png)](http://travis-ci.org/tulsawebdevs/okletsgo)

#ok, letsgo

A mobile web app to list and add cool events and interesting locations around Oklahoma.

===

##Database Installation Instructions (OSX 10.8)

0.  **Install Xcode and Command Line Tools**
	> You can get Xcode from the Mac App Store. You’ll need at least version 4.4 of Xcode for it to work with OS X Mountain Lion. After the installation, open up Xcode in your /Applications folder. You’d want to go to Xcode -> Preferences -> Downloads tab then install the “Command Line Tools.” After you’re done, quit Xcode and fire up Terminal.

1. **Install Ruby 1.9.3 using RVM**

	```
    \curl -L https://get.rvm.io | bash -s stable --	ruby
    ```

2. **Add RVM to your profile**
 	
 	```
 	vim ~/.profile
 	
 	```
 	> *add the line*
 	
 	```
 	source /Users/shanecowherd/.rvm/scripts/rvm
 	```
 	> *save the file and restart terminal*

2. **Install Homebrew**
 
 	```
 	ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
 	```
 	```
 	brew doctor
 	```
 
3. **Install Mongodb**
 	
 	```
    brew install mongodb
	```

4. **Add the sample data into the database**
	
	*This will import the file okletsgo.csv (in the current folder) to the database.  This uses a few features that requires Ruby 1.9.x*
	
	```
	ruby -rcsv -rjson -e "places = []; CSV.foreach('sample_data/okletsgo.csv', {headers: true}) { |row| r=row.to_hash; r['tags'] = r['tags'].split(/\s*,\s*/); r['location'] = [r.delete('lon').to_f, r.delete('lat').to_f]; r['published'] = true; places << r }; puts places.to_json" | mongoimport -d okletsgo -c places --jsonArray

	```
	> You should see something like…
	
	>> connected to: 127.0.0.1
	
	>> imported n objects
	
5. Start Mongodb

	*This will start mongo, but it won't launch each time you restart your machine, **you will want to run this step each time you start the app**.*


	```          
	mongod
	```
##Starting the app
1. Install Node.js with NVM
2. type `npm start` or `coffee app.coffee` 


