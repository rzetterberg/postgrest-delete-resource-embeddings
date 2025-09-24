POST http://localhost:8080/directors
Prefer: return=representation
Accept: application/vnd.pgrst.object
{
  "name": "John"
}
HTTP 201
[Captures]
director_a_id: jsonpath "$['id']"


POST http://localhost:8080/directors
Prefer: return=representation
Accept: application/vnd.pgrst.object
{
  "name": "Albert"
}
HTTP 201
[Captures]
director_b_id: jsonpath "$['id']"


POST http://localhost:8080/films
Prefer: return=representation
[
  {
    "name": "Movie about dogs",
    "director_id": {{ director_a_id }}
  },
  {
    "name": "Movie about cats",
    "director_id": {{ director_a_id }}
  },
  {
    "name": "Movie about cows",
    "director_id": {{ director_a_id }}
  },
  {
    "name": "Movie about cars",
    "director_id": {{ director_b_id }}
  },
  {
    "name": "Movie about trains",
    "director_id": {{ director_b_id }}
  }
]
HTTP 201
[Asserts]
jsonpath "$" count == 5


GET http://localhost:8080/films?select=*,director:directors!inner(name)&director.name=eq.John
HTTP 200
[Asserts]
jsonpath "$" count == 3


GET http://localhost:8080/films?select=*,director:directors!inner(name)&director.name=eq.Albert
HTTP 200
[Asserts]
jsonpath "$" count == 2


DELETE http://localhost:8080/films?select=*,director:directors!inner(name)&director.name=eq.Albert
HTTP 204


GET http://localhost:8080/films
HTTP 200
[Asserts]
jsonpath "$" count == 3