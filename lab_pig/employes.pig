-- Charger les fichiers
employees = LOAD '/input/employees.txt' USING PigStorage(',') AS 
    (ID:int, Nom:chararray, Prenom:chararray, depno:int, Region:chararray, Salaire:double);

departments = LOAD '/input/departements.txt' USING PigStorage(',') AS
    (depno:int, dept_name:chararray);

-- 1. Salaire moyen par département
emp_dept = JOIN employees BY depno, departments BY depno;
avg_salary = FOREACH (GROUP emp_dept BY dept_name) GENERATE group AS dept_name, AVG(emp_dept.Salaire) AS avg_salaire;
STORE avg_salary INTO '/pigout/avg_salary';

-- 2. Nombre d'employés par département
count_emp = FOREACH (GROUP emp_dept BY dept_name) GENERATE group AS dept_name, COUNT(emp_dept) AS nb_emp;
STORE count_emp INTO '/pigout/count_emp';

-- 3. Liste des employés avec leurs départements
emp_list = FOREACH emp_dept GENERATE Nom, Prenom, dept_name;
STORE emp_list INTO '/pigout/emp_list';

-- 4. Employés avec salaire > 60000
high_salary = FILTER emp_dept BY Salaire > 60000;
STORE high_salary INTO '/pigout/high_salary';

-- 5. Département avec salaire le plus élevé
max_salary_dep = ORDER avg_salary BY avg_salaire DESC;
STORE max_salary_dep INTO '/pigout/max_salary_dep';

-- 6. Départements sans employés
all_dept = FOREACH departments GENERATE dept_name;
with_emp = FOREACH (GROUP emp_dept BY dept_name) GENERATE group AS dept_name;
dept_no_emp = FILTER all_dept BY NOT dept_name IN with_emp;
STORE dept_no_emp INTO '/pigout/dept_no_emp';

-- 7. Nombre total d'employés
total_emp = FOREACH (GROUP employees ALL) GENERATE COUNT(employees) AS total_employees;
STORE total_emp INTO '/pigout/total_emp';

-- 8. Employés de Paris
emp_paris = FILTER employees BY Region == 'Paris';
STORE emp_paris INTO '/pigout/emp_paris';

-- 9. Salaire total par ville
salary_city = FOREACH (GROUP employees BY Region) GENERATE group AS ville, SUM(employees.Salaire) AS total_salaire;
STORE salary_city INTO '/pigout/salary_city';

-- 10. Départements avec femmes
-- supposons qu'il y a une colonne genre : Gender: chararray
-- employees = LOAD ... AS (..., Gender:chararray);
femmes = FILTER employees BY Gender == 'F';
fem_dept = FOREACH (GROUP femmes BY depno) GENERATE group AS depno;
STORE fem_dept INTO '/pigout/employes_femmes';


-- Films américains par année
moviesUSA = FILTER movies BY country == 'USA';
mUSA_annee = FOREACH (GROUP moviesUSA BY year) GENERATE group AS year, moviesUSA;

-- Films américains par réalisateur
mUSA_director = FOREACH (GROUP moviesUSA BY director) GENERATE group AS director, moviesUSA;

-- Triplets (idFilm, idActeur, role)
mUSA_acteurs = FOREACH moviesUSA GENERATE _id AS movieId, FLATTEN(actors) AS actorTuple;
mUSA_acteurs = FOREACH mUSA_acteurs GENERATE movieId, actorTuple._id AS actorId, actorTuple.role AS role;

-- MoviesActors : join avec artists
moviesActors = JOIN mUSA_acteurs BY actorId, artists BY _id;
moviesActors = FOREACH moviesActors GENERATE mUSA_acteurs::movieId, CONCAT(artists::first_name, ' ', artists::last_name) AS actor_name, role;

-- FullMovies : join movie description + acteurs
fullMovies = JOIN moviesUSA BY _id, moviesActors BY movieId;
fullMovies_group = GROUP fullMovies BY moviesUSA::_id;
fullMovies_final = FOREACH fullMovies_group GENERATE group AS movieId, FLATTEN(fullMovies);

-- ActeursRealisateurs
-- (requiert cogroup par artiste et films réalisés/joués)
