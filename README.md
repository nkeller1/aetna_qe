# qa_api_code_test

It is time to run some tests against OMDb API - The Open Movie Database!

Tips:
  - You can find documentation on the api at http://www.omdbapi.com/#usage
  - Information on MiniTest can be found at https://github.com/seattlerb/minitest
  - Use byebug to pause/debug test execution

1) Fetch a personal api key for omdbapi.com to implement on all of your api requests

2) Add an assertion to suite/test_no_api_key to ensure the response at runtime matches what is currently displayed with the api key missing  
 
3) Extend suite/api_test.rb by creating a test that performs a search on 'thomas'.  
(note: you can use a different search term, but we are not responsible for the display of any content returned)
    - Verify all titles are a relevant match
    - Verify keys include Title, Year, imdbID, Type, and Poster for all records in the response
    - Verify values are all string
    - Verify year matches correct format

4) Add a test that verifies each imdbID on page 1 is valid (e.g. not orphaned)

5) Add a test that verifies none of the poster links on page 1 are broken
 
6) Add a test that verifies there are no duplicate records across the first 5 pages

7) Have a paging test which verifies the lower boundary and upper boundary of page numbers 
     and that the number of records on the last page matches the number that should exist on the last page
  
8) Take any of the logic established in your work and add improvements (e.g. DRY Principle, reusability, or other refactoring)