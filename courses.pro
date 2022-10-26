/* 
The following is a course scheduling tool in Prolog.
The first part defines a database of courses with their pre-requisites
and co-requisites taken from the current Computer Engineering undergraduate
curriculum.  It does not include courses picked from a list such as
humanities, STS, and tedchnical electives, only the required courses.
Next comes a section of predicats that defines which of these courses have
already been taken and the egrade assigned.  We aren't going to use the
grade but you can see how we might expand it.  I only have a couple of
these entered, you can use them, remove them, or add more if you like to
test different situations.
After that are rules.  Near the bottom the main user interface is the
check_course and check_schedule predicates that check to see if all the
requirements are satisfied.  The first takes a single course name, and
the latter takes a list of courses.  Both return a list of missing 
pre-requisites and a list of missing co-requisites.  In the case of
check_schedule if a ico-requisite course is listed in the schedule it
should not appear as missing.  If a course has already been taken, the
code prints a simple error message and returns fail.  The other predicates
represent a stepwise implementation of these two, and simple utilities
that let you explore the relationships in the database.  They are fairly
easy so you should do them first, and then use them to implement the more
complex ones.  The last predicate is suggest_course that tries to pick a
course that has not been taken and has all of its requisites completed.
You are free to add other predicates you feel you need in order to
implement the required ones.  There is more than one way to solve the
problems.  You will also want to look at built-in predicates either via
the documentation or the apropos and help predicates in SWIPL.  In
particular this predicate may be useful:

append(List1,List2,List+List2).
*/

/* course( <course-name>, <pre-req list>, <co-req list> ). */

course(ch1010,[],[]).
course(cpsc1110,[],[]).
course(ece2010,[],[]).
course(ece2020,[math1080],[phys2210]).
course(ece2090,[],[]).
course(ece2110,[],[ece2020]).
course(ece2120,[ece2110],[ece2620]).
course(ece2220,[cpsc1110],[]).
course(ece2230,[ece2220],[]).
course(ece2620,[ece2020,phys2210,math2060],[]).
course(ece2720,[ece2010,cpsc1110],[]).
course(ece2730,[],[ece2720]).
course(ece3110,[ece2120],[]).
course(ece3170,[ece2620,math2080],[ece3300]).
course(ece3220,[ece2720,ece2230],[]).
course(ece3270,[ece3710],[]).
course(ece3300,[ece2620,math2080],[]).
course(ece3520,[ece2230],[math4190]).
course(ece3710,[ece2720],[ece2620]).
course(ece3720,[],[ece3710]).
course(ece4090,[ece3300],[]).
course(ece4950,[ece3710,ece2230,ece3300],[ece4090]).
course(ece4960,[ece3270,ece3520,ece4950,ece4090],[]).
course(engl1030,[],[]).
course(engr1020,[],[]).
course(engr1410,[engr1020],[]).
course(math1060,[],[]).
course(math1080,[math1060],[]).
course(math2060,[math1080],[]).
course(math2080,[math2060],[]).
course(math3110,[math1080],[]).
course(math4190,[math3110],[]).
course(phys1120,[],[math1060]).
course(phys2210,[],[math1080]).

/* completed( <course-name>, <grade> ) */

completed(C) :- completed(C,_).

completed(engr1020,a).
completed(ch1010,b).
completed(ece2020,b).
completed(ece3710,b).
completed(math1080,a).
completed(phys2210,a).
completed(engl1030,b).

/* RULES */

/* returns true if all courses are completed */
complete_all([]).
complete_all([X|Y]) :- completed(X), complete_all(Y).

/* return courses in Req-List not completed */
missing_req(Req,Missing) :- exclude(completed, Req, Missing).

% /* return true if all pre-reqs satisified for Course */
prereq_satisfied(Course) :- course(Course, X, _), complete_all(X).

% /* return a list of missing pre-reqs for Course */
prereq_missing(Course,NP) :- course(Course, X, _), missing_req(X, NP).

% /* return true if all co-reqs satisified for Course */
coreq_satisfied(Course) :- course(Course, _, X), complete_all(X).

% /* return a list of missing co-reqs for Course */
coreq_missing(Course,NC) :- course(Course, _, X), missing_req(X, NC).

% /* return lists of missing pre-reqs in L1 and co-reqs in L2 for course C */
% /* prints a message if course is already completed */
check_course(C,L1,L2) :- not(completed(C)), prereq_missing(C,L1), coreq_missing(C,L2).
check_course(C,_,_) :- completed(C), nl, write('Course already completed.'), nl, fail.

% /* prints all of the missing pre-reqs in L1 and co-reqs in L2 for all */
% /* courses in LC or returns true if there are none missing */
not_completed(C) :- not(completed(C)).
none_missing(Course) :- prereq_satisfied(Course), coreq_satisfied(Course).
is_course(C) :- course(C,_,_).
% the tail here ensures the output is not "[correct items|_]"
check_schedule_([],_,C,D) :- maplist(is_course, C), maplist(is_course, D).
check_schedule_([A|B],Courses,PrereqAll,CoreqAll) :- check_course(A,PrereqCourse,CoreqCourse), subset(PrereqCourse,PrereqAll),
    append(Courses,CoreqAll,CoreqAllPlusCurrent), subset(CoreqCourse,CoreqAllPlusCurrent),
    check_schedule_(B,Courses,PrereqAll,CoreqAll).
check_schedule(LC,_,_) :- not(maplist(not_completed, LC)), nl, write('List contains completed course.'), nl, !, fail.
check_schedule(LC,_,_) :- maplist(none_missing, LC).
check_schedule(LC,L1,L2) :- check_schedule_(LC,LC,L1,L2). 

/* prints one (or more) courses that are not completed and do have their */
/* requisites satisfied. */
suggest_course(C) :- course(C, X, Y), not(completed(C)), complete_all(X), complete_all(Y).
