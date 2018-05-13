# Codesio
## What is it?
Codesio is a small code snippet aggreation web-app I'm writing.
You will be able to submit code snippets, search them, tag them do some more complex filtering etc.

The idea came about when I turned to my friend [Nick](https://github.com/computerfreak) and asked him for a project idea I could do in a week or two.
After talking a bit he was like,
"You know sometimes I know what I want to do and understand the concept and just want to see an implementation in whatever language I'm working in without the comments or question section."
So here we are.

Basically, the web app is a simple crud application with a little bells and whistles on top to accomodate the dynamic language highlighting and special search.
Elasticsearch tends to work well for things like this so I use ES to handle the more complex querying and then if I have the time since one of my main interests is
ML I will implement an auto tagger. If I continue doing this past the two weeks I may even write a content crawler.

## Features that are finished:
 - Account creation and login
 - Realtime search for snippets using elasticsearch and phoenix channels + websockets
 - Adding, editing, deleting, inspecting Snippets
 - filters/sorts (language, time)
 - Rating snippets, sorting by highest rated

## Features to be finished shortly:
 - All the UI styling
 - list of all snippets submitted by a user

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
