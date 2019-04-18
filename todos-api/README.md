# todos-api

This service is written in NodeJS, it provides CRUD operations over TODO entries.
It keeps all the data in memory. CREATE and DELETE operations are logged by
sending appropriate message to a Redis queue. The messages are then processed by
`log-message-processor`.

Following API endpoints are exposed:

- `GET /todos` - list all TODOs for a given user, user ID is taken from JWT
- `POST /todos` - create new TODO
- `DELETE /todos/:taskId` - modify a TODO by ID

TODO object looks like this:
```
{
    id: 1,
    userId: 1,
    content: "Create new todo"
}
```

Log message looks like this:
```
{
    opName: CREATE,
    username: username,
    todoId: 5,
}
```

## Configuration

The service scans environment for variables:
- `TODO_API_PORT` - the port the service takes.
- `JWT_SECRET` - secret value for JWT token processing.
- `REDIS_HOST` - host of Redis
- `REDIS_PORT` - port of Redis
- `REDIS_CHANNEL` - channel the processor is going to listen to

## Building and running

```
npm install
JWT_SECRET=foo TODO_API_PORT=8082  npm start
```

## Usage

To fetch the access token, 

```
 curl -X POST  172.27.0.3:8081/login -d '{"username": "devops","password": "demo"}' 
```

[sample output]

```
{"accessToken":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTU4MjEzMDksImZpcnN0bmFtZSI6IkRldm9wcyIsImxhc3RuYW1lIjoiRGVtbyIsInJvbGUiOiJVU0VSIiwidXNlcm5hbWUiOiJkZXZvcHMifQ.8fJkOr-MmTCTrll8uV1K0GE2Fpk0X73zeK2Sfbw89iI"}

```

set the $token as environment variable using the value given above, 

e.g. 
```
export token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTU4MjEzMDksImZpcnN0bmFtZSI6IkRldm9wcyIsImxhc3RuYW1lIjoiRGVtbyIsInJvbGUiOiJVU0VSIiwidXNlcm5hbWUiOiJkZXZvcHMifQ.8fJkOr-MmTCTrll8uV1K0GE2Fpk0X73zeK2Sfbw89iI
```

and then run the following commands to either fetch from or to write to the **todos-api** service 

```
 curl -X GET -H "Authorization: Bearer $token" 127.0.0.1:8082/todos
 curl -X POST -H "Authorization: Bearer $token" 127.0.0.1:8082/todos -d "content=deal with that"
```
