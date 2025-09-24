-- Make sure postgrest reloads the schema when sqitch applies changes
DROP EVENT TRIGGER IF EXISTS on_ddl_change CASCADE;

 CREATE OR REPLACE FUNCTION sqitch.notify_ddl_change()
RETURNS event_trigger
AS $$
  BEGIN
    NOTIFY pgrst, 'reload schema';
  END;
$$ LANGUAGE plpgsql;

 CREATE EVENT TRIGGER on_ddl_change ON ddl_command_end
EXECUTE FUNCTION sqitch.notify_ddl_change();

BEGIN;

--=================================================================================
-- Example tables
--=================================================================================

CREATE SCHEMA example;

CREATE TABLE example.directors (
  id   serial PRIMARY KEY,
  name text   NOT NULL,

  UNIQUE(name)
);

CREATE TABLE example.films (
  id          serial PRIMARY KEY,
  name        text   NOT NULL,
  director_id serial NOT NULL REFERENCES example.directors (id) ON DELETE CASCADE,

  UNIQUE(name)
);

--=================================================================================
-- API
--=================================================================================

CREATE SCHEMA api;

CREATE VIEW api.directors WITH (security_invoker = true) AS
  SELECT *
    FROM example.directors;

CREATE VIEW api.films WITH (security_invoker = true) AS
  SELECT *
    FROM example.films;

--=================================================================================
-- Permissions
--=================================================================================

CREATE ROLE anonymous WITH NOLOGIN;

GRANT anonymous TO authenticator;

GRANT USAGE
   ON SCHEMA public
           , example
           , api
   TO anonymous;

GRANT USAGE, SELECT ON ALL SEQUENCES
   IN SCHEMA example
   TO anonymous;

GRANT SELECT, INSERT, UPDATE, DELETE
   ON TABLE example.directors
          , example.films
          , api.directors
          , api.films
   TO anonymous;

COMMIT;
