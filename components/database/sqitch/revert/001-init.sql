BEGIN;

REVOKE SELECT, INSERT, UPDATE, DELETE
    ON TABLE example.directors
           , example.films
           , api.directors
           , api.films
  FROM anonymous;

REVOKE USAGE, SELECT ON ALL SEQUENCES
    IN SCHEMA example
  FROM anonymous;

REVOKE USAGE
    ON SCHEMA public
            , example
            , api
  FROM anonymous;

REVOKE anonymous FROM authenticator;

DROP SCHEMA api CASCADE;
DROP SCHEMA example CASCADE;

DROP ROLE anonymous;

DROP EVENT TRIGGER IF EXISTS on_ddl_change;
DROP FUNCTION IF EXISTS sqitch.notify_ddl_change();

COMMIT;
