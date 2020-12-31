
## Notes From Nathan

## Setup
1. Clone down the repo.

2. `bundle install`

3. Dotenv has been added to the gem list. [Docs](https://github.com/bkeepers/dotenv) for dotenv.
  - Create a .env file in the root directory. 
  - Add the following line of code on line 1 of the newly created .env file. Use your API Key
```
  export OMDB_API_KEY=YOUR_API_KEY
```
   - The .env file has already been added to .gitignore

4. 'Master' branch has been renamed to 'main'.

To meet the following criteria `You must use minitest and faraday as supplied, and follow the existing pattern of api requests in test_no_api_key.` I have added a puts in each test BUT I have commented out the line. If you choose to run each test individually please comment back in the 'puts' line in to see the response in the terminal. 
 

## I have left comments in line in the test file to document my reasoning and observations.

## Assumptions

1. I (mostly) stuck to testing the 'By Search (s)' parameter for edge case and additional testing since most of the acceptance criteria revolved around the 's' parameter.
2. While it seems like performance testing outside of the acceptance criteria, it would be a good idea. 
3. I chose not to use VCR at this time as I wanted to test calls in action and didn't think I would even come close to the 1000 per day limit. VCR is usually a gem I make part of my standard library. 
4. I followed a typical git workflow with commit and branch histopry rather than commiting to main.


# QA API Code Test

It is time to run some tests against OMDb API - The Open Movie Database!

## Tips:

- You can find the main api page at http://www.omdbapi.com
- You must use minitest and faraday as supplied, and follow the existing pattern of api requests in test_no_api_key.
- You may add or change other gems as you see the need. (For example, 'pry' is supplied debugging but you may use another debugger.)
- Completed repo should allow for easy setup/running of your test file.
- Unique or helpful information should be documented in the readme.

## Tasks:

1. Successfully make api requests to omdbapi from within tests in api_test.rb

2. Add an assertion to test_no_api_key to ensure the response at runtime matches what is currently displayed with the api key missing

3. Extend api_test.rb by creating a test that performs a search on 'thomas'.

  - Verify all titles are a relevant match
  - Verify keys include Title, Year, imdbID, Type, and Poster for all records in the response
  - Verify values are all of the correct object class
  - Verify year matches correct format

4. Add a test that uses the i parameter to verify each title on page 1 is accessible via imdbID

5. Add a test that verifies none of the poster links on page 1 are broken

6. Add a test that verifies there are no duplicate records across the first 5 pages

7. Add a test that verifies something you are curious about with regard to movies or data in the database.

