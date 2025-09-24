BEGIN;

SELECT * FROM example.films;
SELECT * FROM example.directors;
SELECT * FROM api.films;
SELECT * FROM api.directors;

ROLLBACK;
