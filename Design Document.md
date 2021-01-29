# The job database project

I wanted to start deepening my experience with databases and I found online SQL clunky. Clunky both because I wasn't asking my own questions and because I didn't have a strong intuition for how databases were organized. So I figured I'd try to build a simple database on my own and then ask some questions that I actually cared about on that data. I'd started collecting notes on my job hunt, so translating those notes into a database seemed like the perfect project. I'm certainly highly motivated to understand these data. 

The goal of this project is not to create the perfect database but to have a chance to think about the sub-parts of these systems. It's also a chance for me to be better about putting tangible products into world that aren't as polished as humanly possibly. In the academic settings I've been a part of, it's often looked down on to admit that you don't know things and I've worked very hard to keep myself willing to acknowledge, and joyfully embrace, my own ignorance. That said, for the last few years I've been lucky enough to be able to think deeply about anything that becomes a product (here something that has to stand on it's own merits, without me there to moderate how people interact with it) and so I've grown complacent in this aspect of embracing my ignorance. All this is a fancy way of saying that I haven't been showing rough(ish) drafts to strangers and I'm glad to have a chance to do more of it. In this spirit, I'm going to try my best to have any brainstorming write-ups match my actual thought process on the project, even if it makes me feel like an idiot that I didn't think of certain things earlier in the process. 

In this document I'll describe the notes I've taken so far and then transition those notes into a normalized database structure. 

## My notes

I have a pretty wide array of notes related to my job hunt. I have a document with high level notes: 
* what are my goals, 
* my strengths, my weaknesses, 
* general direction for what do I need to do to both highlight those strengths and shore up those weaknesses to achieve those goals[^1]. 
 
I also have a daily summary of what I worked on, whether it was job applications, document writing, online classes, or things like this blog. For now, I'm going to ignore these notes. The high level notes are more way useful to have in one place where I can see them at once. The job hunting diary could be useful down the line (especially for some basic Natural Language Processing projects) but not more useful to have in a relational database. 

Now for the good part: applications and interviews. Right now, I have the following information for essentially all applications: company name, position name, date applied. If I've gotten an interview with a company, I add the following: number of interviews, as well as text notes from notable interviews and a overall company note. Right now I have these stored in probably the worst way possible, a giant text document where each application gets a line (I know, I'm a monster). However this format makes it easy to group the lines based on various criteria. Those criteria are: 
* Is the application active (do I have a reasonable chance of hearing from this company). Active applications either have an interview scheduled, I'm working on a coding challenge, or I'm waiting for a response. Here waiting for a response includes two options: a person in the company has told me that I should expect to hear from them or it's a new application which is less than two weeks old (this is a rough heuristic which so far seems reasonable $90\%$ of the time)
* Inactive applications include new applications which went more than two weeks without a response and applications in which I've received a formal rejection. There's an important subclass of applications with a formal rejection which are those that said no for now, i.e. they're interested in me but the role I applied for wasn't the right fit. 

Now one of the fun things about this project is that I have an opportunity to think a little more deeply about the data I collect and if it should be more detailed than what I currently do. However I'm going to leave such musings to future iterations and instead focus on getting my current note structure into a database. 

[^1]: This is the part where I tell you that I'm very good at math and creative problem solving. 

## Database Structure
### Pre-Normalization
My end goal is to have a normalized database, but instead of directly trying to figure out the structure I'm going to convert the current note structure into a record structure and normalize from there. 

The first few elements of the application record are pretty clear. Company name, position name, date applied, number of interviews, and company notes fit easily in one record. Let's assume for now that there will be max $5$ interviews at a company, which would require $5$ places for interview notes. Additionally let's assume that every grouping that I describe in the text above should get its own flag. Then let's add an active flag (1 if active, else 0), an active status (1, interview scheduled, 2 working on coding challenge, 3 waiting for a response because I heard from the company, 4 waiting for a response because I recently applied), as well as an inactive status(1, more than two weeks have passed, 2 rejected, 3 no for now). I'm going to assume for now that an active flag of 1 will have an inactive status of Null (no assigned inactive status) and an active flag of 0 will have an active status of Null. 

Then columns in this database would look like:

Primary Key | Company name | Position Name | Date Applied | Active Flag | Active Status | Inactive Status | Company Notes| Interview 1 Notes|...| Interview 5 Notes|

### Normalization
I want to take a look at two factors to improve the design of this database.
1. Potential sub-tables and how they're related
2. How a record will be updated. 
####  Sub-records
The first place I'm doing to start for looking at sub-records is with the relationship between interviews and applications, primarily because I had to make an assumption (no more that $5$ interviews) to get my initial record structure. Building a record structure that allows for different numbers of interviews lets the database be more flexible and I won't need to go back and change things if my assumption is violated. Each application could lead to many interviews (hopefully) i.e. it is a [ONE to MANY relationship](https://en.wikipedia.org/wiki/One-to-many_(data_model)).

There's another clear one to many relationship in the database: one company can have many positions. The position to application relationship is slightly more complicated. At first glance, this seems like a one to one relationship. One position, one application (many interviews). Unfortunately it has happened to me in the past that in hopping between different websites that I accidentally have applied more than once to a position. I've also seen the same job appear get posted multiple times. Based on the career sites I've read, it can be reasonable to reapply if you've changed your application. This can include adding keywords to your resume or gaining/including new experience. So I'm going to treat this as a one to many relationship as well. 

So finally I have 4 entities: Company, Position, Application, Interview. There's a one to many relationship between Company and Position, Position and Application, Application and Interview. 

To deal with a ONE to MANY structure requires that each of the MANY stores the ID of the ONE. That gives a structure which is:
Company Table
Elements: Company ID, Company Name, Company Notes

Position Table:
Elements: Position ID, Position Name, Company ID

Application Table:
Elements: Application ID, Date Applied, Active Flag, Active Status, Inactive Status, Position ID

Interview Table
Elements: Interview ID, Interview Notes, Application ID

#### Modification
The Company, Position, and Interview Tables are pretty simple, however the Application table has a number of tracking flags which require a bit more thought. At many points in the interview process, a given Application will need to be updated from Active to Inactive or the status will have to change. Based on the initial setup of the Application table, to correctly change an Application from active to inactive will require changing 3 columns. Active flag has to be set to zero, Active Flag should be set to Null, Inactive Flag should be changed to the appropriate value. That means that if I'm rushed and I only update the active flag of a given application, then I'm going to break the rules of the database and potentially mess up future queries [^2]. 

With this in mind, I'm going to change the structure to make it future me proof. To do this I'm going to need to think a little bit about the queries I'm going to want to make to this database. Let's start with the most frequent queries. First, I want to generate a list of applications where there's a potential that I need to do something. Second, I want to see all the applications where I still have a chance to get a job. Third and least frequently, I'd like to be able to get a high level view of the job application process. How many applications did I send out, how many lead to interviews, etc. Let's tackle those in order.

* Applications where I might need to do something. This includes companies where I have an interview scheduled (I need to prep for the interview), companies where I'm working on a coding challenge, companies where I'm waiting for a response after contact from the company (it might have been long enough that I should reach out), and "no for now" companies where it's been long enough to no longer be now. I'm going to handle this by adding a date of next action column. That way I can prioritize things that need to happen soon without losing long time horizon applications. For completeness, I'm also going to add a next action column, which will be a string to remind me what I wanted to do. It's not strictly necessary to get company lists, but it will enhance my use of the database a lot.   
* Applications where I might get a job. This includes the above plus applications where I haven't had a formal rejection. To handle this, I'm going to add a rejected flag. It might be possible to do without it, by setting a date of next action for every new application two weeks in the future and setting date of next action to Null for every rejection. Then I could look for every row with a date of next action to get this list. However, that's going to add a lot of noise to the previous query and I'd like to be able to relax the two week rule when appropriate. For example, over the holidays 2 weeks is probably too short. Now I can search for all applications without a rejection and to an application date within two weeks to get my old active list. 
* High level view. This actually doesn't require anything more than the previous two. The examples I gave can be done by counting the number of rows in the Application table and the number of unique Application IDs in the Interview table.

So the database structure is

Company Table
Elements: Company ID, Company Name, Company Notes

Position Table:
Elements: Position ID, Position Name, Company ID

Application Table:
Elements: Application ID, Date Applied, Date Next Action, Action, Rejected, Position ID

Interview Table
Elements: Interview ID, Interview Notes, Application ID

#### What am I missing?
Before finalizing the structure of the database, I wanted to take a step back and ask if I was missing anything. I've certainly had it happen before that my current perspective blinds me to something important about the end user or audience of the product and so I've found it never hurts to step back and do a quick double check if I'm being an obvious idiot (it's much trickier if I'm a subtle idiot). This is balanced by the danger of adding a bunch of very exciting bells and whistles that ultimately won't be used but worth it all the same. 

So looking at the table structure, a few things jump out to me. 
1. I didn't include anywhere to mark whether I got an offer, or took the job. Without it, this table becomes useful for exactly $1$ job hunt but requires modification for the next one. Two ways to deal with this occur to me. First, change the Rejected flag to an Outcome flag. Now instead of 0 (no rejected) or 1 (rejected), it can be 0 (in progress), 1(rejected), 2 (offer),3 (accepted). Or equivalently one of the four strings In progress, Rejected, Offer, Accepted. Honestly now that I've thought of this, the past table structure seems pretty silly. Second, add an Offer Table. Given that I forgot to account for offers in my initial design, I'm going to put this in the unnecessary bells and whistles section for now.
2. There's some obvious missing information, aka there are a range of potential columns that I could add for completeness or for future projects. The first few that come to mind: a link for the company website, a link for the job posting or the job posting text, when the job was posted, when I had the interview, who I interviewed with, information about what resume I used to submit to the job. Almost all of these are in the unnecessary bells and whistles section. The resume information would be another table, the job posting text might be helpful but would require building more tools to analyze, the links and who I interviewed seem nice to have but I don't know how I would use them. The only item that seems like it would be easy to extract meaningful information about the job hunt from is the interview date. I'd be able to get a better feel for the patterns of a particular company and potentially use this information to update my application table. 

Then the final structure is:

Company Table
Elements: Company ID, Company Name, Company Notes

Position Table:
Elements: Position ID, Position Name, Company ID

Application Table:
Elements: Application ID, Date Applied, Outcome, Date Next Action, Action, Position ID

Interview Table
Elements: Interview ID, Interview Date, Interview Notes, Application ID


[^2]: This seems related to the concept of [ACID](https://en.wikipedia.org/wiki/ACID) from database management systems, a set of rules built into the programs like mySQL or (insert your favorite here) to ensure that transactions will work as intended. From what little research I've done so far it doesn't seem like the link to ACID explicitly pops up in database design, so this could be a case where I just lack enough subtlety in understanding to enforce the boundary between the database and the system that interacts with the database.     




