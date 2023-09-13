BDD Specs

Story: Customer requests to see the feed

Narrative #1

As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newest images of my friends

Scenarios

Given the customer has connectivity
When the customer requests to see the feed
Then the app should display the latest feed from remote
    And replace the cache with the new feed
    
    
Narrative #2

As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends

Scenarios

Given the customer does not have connectivity
When the customer requests to see the feed
Then the app should display the latest feed saved

Given the customer does not have connectivity
And the cache is empty
When the customer requests to see the feed
The app should display an error message
