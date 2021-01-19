# Implementation To Do

Research how the MySQL code and database will live on Github:
    Database should live locally, MySQL code will be on Github (table set up and subset of data) +summary docs

Implement tables:

Company Table
Elements: Company ID, Company Name, Company Notes

Position Table:
Elements: Position ID, Position Name, Company ID

Application Table:
Elements: Application ID, Date Applied, Outcome, Date Next Action, Action, Position ID

Interview Table
Elements: Interview ID, Interview Date, Interview Notes, Application ID

# Random Thoughts for later

All elements in the MANY part of a ONE to MANY relationship need Primary Key, Foreign Key

When selecting how to represent names, typically people use varchar (variable characters up to some limit) however this will break on names that use characters outside of the non-Unicode characters. You can use instead nvarchar. It takes twice the space, however it also allows for more characters. Small database anyway, let's use nvarchar. [More here. ](https://stackoverflow.com/questions/144283/what-is-the-difference-between-varchar-and-nvarchar)

