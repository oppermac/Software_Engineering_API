#Source: Michael Galarnyk - "Accessing Data from Github API using R" Accessed 21-Nov-2020

#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)
#install.packages("plotly")
library(plotly)
require(devtools)

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

################



# There are two methods of interrogating data. The above allows you to go through the JSON data.
# Below I am going to interrogate another user and put there data into a data.frame
# Using user Linus 'torvalds'

userData = GET("https://api.github.com/users/torvalds/followers?per_page=100;", gtoken)
stop_for_status(userData)

# Extract content from torvalds

extract = content(userData)

# Convert content to dataframe

githubDB = jsonlite::fromJSON(jsonlite::toJSON(extract))

# Subset dataframe

githubDB$login

# Retrieve a list of usernames

id = githubDB$login
user_ids = c(id)

# Create an empty vector and data.frame

users = c()
usersDB = data.frame(

  username = integer(),
  following = integer(),
  followers = integer(),
  repos = integer(),
  dateCreated = integer()

)

# Loop through users and find users to add to list

for(i in 1:length(user_ids))
{
  #Retrieve a list of individual users
  followingURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followingRequest = GET(followingURL, gtoken)
  followingContent = content(followingRequest)

  #Ignore if they have no followers
  if(length(followingContent) == 0)
  {
    next
  }

  followingDF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = followingDF$login

  #Loop through 'following' users
  for(j in 1:length(followingLogin))
  {
    #Check that the user is not already in the list of users
    if(is.element(followingLogin[j], users) == FALSE)
    {
      #Add user to list of users
      users[length(users) + 1] = followingLogin[j]

      #Retrieve data on each user
      followingUrl2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
      following2 = GET(followingUrl2, gtoken)
      followingContent2 = content(following2)
      followingDF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))

      #Retrieve each users following
      followingNumber = followingDF2$following

      #Retrieve each users followers
      followersNumber = followingDF2$followers

      #Retrieve each users number of repositories
      reposNumber = followingDF2$public_repos

      #Retrieve year which each user joined Github
      yearCreated = substr(followingDF2$created_at, start = 1, stop = 4)

      #Add users data to a new row in dataframe
      usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearCreated)

    }
    next
  }
  #Stop when there are more than 200 users
  if(length(users) > 200)
  {
    break
  }
  next
}


#Link R to plotly. This creates online interactive graphs based on the d3js library
Sys.setenv("plotly_username"="oppermac")
Sys.setenv("plotly_api_key"="ZrEIciIVYXHUSnSP2XwP")

plot1 = plot_ly(data = usersDB, x = ~repos, y = ~followers,
                text = ~paste("Followers: ", followers, "<br>Repositories: ",
                              repos, "<br>Date Created:", dateCreated), color = ~dateCreated)
plot1

#Upload the plot to Plotly
Sys.setenv("plotly_username"="oppermac")
Sys.setenv("plotly_api_key"="ZrEIciIVYXHUSnSP2XwP")
api_create(plot1, filename = "Followers vs Repositories by Date")
#PLOTLY LINK: https://plot.ly/~oppermac/1

plot2 = plot_ly(data = usersDB, x = ~following, y = ~followers,
                text = ~paste("Followers: ", followers, "<br>Following: ",
                              following))
plot2

#Upload the plot to Plotly
Sys.setenv("plotly_username"="oppermac")
Sys.setenv("plotly_api_key"="ZrEIciIVYXHUSnSP2XwP")
api_create(plot2, filename = "Followers vs Following")
#PLOTLY LINK: https://plot.ly/~oppermac/3/


#LANGUAGES BREAKDOWN
#The following code finds the most popular language for each user

#Create empty vector
Languages = c()

#Loop through all the users
for (i in 1:length(user_ids))
{
  #Access each users repositories and save in a dataframe
  RepositoriesUrl = paste("https://api.github.com/users/", user_ids[i], "/repos", sep = "")
  Repositories = GET(RepositoriesUrl, gtoken)
  RepositoriesContent = content(Repositories)
  RepositoriesDF = jsonlite::fromJSON(jsonlite::toJSON(RepositoriesContent))

  #Find names of all the repositories for the given user
  RepositoriesNames = RepositoriesDF$name

  #Loop through all the repositories of an individual user
  for (j in 1: length(RepositoriesNames))
  {
    #Find all repositories and save in data frame
    RepositoriesUrl2 = paste("https://api.github.com/repos/", users[i], "/", RepositoriesNames[j], sep = "")
    Repositories2 = GET(RepositoriesUrl2, gtoken)
    RepositoriesContent2 = content(Repositories2)
    RepositoriesDF2 = jsonlite::fromJSON(jsonlite::toJSON(RepositoriesContent2))

    #Find the language which each repository was written in
    Language = RepositoriesDF2$language

    #Skip a repository if it has no language
    if (length(Language) != 0 && Language != "<NA>")
    {
      #Add the languages to a list
      Languages[length(Languages)+1] = Language
    }
    next
  }
  next
}

#Save the top languages in a table
LanguageTable = sort(table(Languages), increasing=TRUE)

#Save this table as a data frame
LanguageDF = as.data.frame(LanguageTable)

#Plot the data frame of languages
plot3 = plot_ly(data = languageDF, labels = ~languageDF$languages, values = ~languageDF$Freq, type = "pie")
plot3

#Upload the plot to Plotly
Sys.setenv("plotly_username"="oppermac")
Sys.setenv("plotly_api_key"="ZrEIciIVYXHUSnSP2XwP")
api_create(plot3, filename = "10 Most Popular Languages")
#PLOTLY LINK: https://plot.ly/~oppermac/7/
