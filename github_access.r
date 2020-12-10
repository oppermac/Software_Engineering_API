#Source: Michael Galarnyk - "Accessing Data from Github API using R" Accessed 21-Nov-2020

#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)

# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you
myapp <- oauth_app(appname = "Software_Engineering_API",
                   key = "fd486685b12a99b74007",
                   secret = "7c7600d6ee171ffbd49891223d30f80749b36762")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/oppermac/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
reqContent = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(reqContent))

# Subset data.frame
gitDF[gitDF$full_name == "oppermac/datasharing", "created_at"]

##################################################

require(devtools)

### Collecting & Displaying My Data - "oppermac" is my login
# Get my data
oppermacData = fromJSON("https://api.github.com/users/oppermac")

# Display the number of followers
oppermacData$followers

# Gives user names of all my followers
followers = fromJSON("https://api.github.com/users/oppermac/followers")
followers$login

# Display the number of users I am following
oppermacData$following

# Gives user names of all the users I am following
following = fromJSON("https://api.github.com/users/oppermac/following")
following$login

# Display the number of repositories I have
oppermacData$public_repos

# Gives the name and creation date for my repositories
repositories = fromJSON("https://api.github.com/users/oppermac/repos")
repositories$name
repositories$created_at


#Seeing as my account is not very active and I have very few followers, I
#decided to see if I could get data for Linus Torvalds GitHub

### Collecting & Displaying Linus' Data
# Get Torvalds' data
torvaldsData = fromJSON("https://api.github.com/users/torvalds")

# Display the number of followers
torvaldsData$followers

# Gives user names of all Torvalds' followers
followers = fromJSON("https://api.github.com/users/torvalds/followers")
followers$login

# Display the number of users Torvalds is following
torvaldsData$following

# Gives user names of all the users Torvalds is following
following = fromJSON("https://api.github.com/users/torvalds/following")
following$login

# Display the number of repositories Torvalds has
torvaldsData$public_repos

# Gives the name and creation date for Torvalds' repositories
repositories = fromJSON("https://api.github.com/users/torvalds/repos")
repositories$name
repositories$created_at


