# App-name ♻

- [Description](#description)
- [Try it out](#try-it-out)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the app](#running-the-app)
- [DB migrations](#db-migrations)
- [Tests](#tests)
- [APIs docs](#apis-docs)
- [Database schema](#database-schema)
- [Project structure tree](#project-structure-tree)
- [Support](#support)

## Description

This repository build as monorepo and consist of ___ project:

1. ...
2. ...
    
Read more about project structure [here](#project-structure-tree).

Building with:

<p>
    <a href="https://nodejs.org/" target="blank">
        <img src="https://nodejs.org/static/images/logos/nodejs-new-pantone-black.svg" height="40" alt="Node.js logo" />
    </a>
    <a href="https://www.typescriptlang.org/" target="blank">
       <img src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Typescript_logo_2020.svg" height="40" alt="TypeScript logo" />
    </a>
    <a href="http://nestjs.com/" target="blank">
       <img src="https://nestjs.com/img/logo_text.svg" height="45" alt="NestJS logo" />
    </a>
    <a href="https://www.postgresql.org/" target="blank">
       <img src="https://www.postgresql.org/media/img/about/press/elephant.png" width="40" alt="PostgreSQL logo" />
    </a>
    <a href="https://www.prisma.io/" target="blank">
        <img src="https://cdn.worldvectorlogo.com/logos/prisma-2.svg" height="40" alt="Prisma logo" />
    </a>
 </p>


## Try it out
<!---
This project contains configured ready to code developer environment with modern [Gitpod](https://www.gitpod.io/) online tool.
To try it just click on the button below:

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://gitlab.com/SP-OKO/security/social/social-security-backend)
-->
## Installation

First of all, make sure you have installed the following software on your environment:

-   [Node.js](https://nodejs.org/) version 14+
-   [PostgreSQL](https://www.postgresql.org/) version 12+

```bash
$ git clone git@gitlab.com:SP-OKO/smart_citi/iot-backend.git
$ cd nest-prisma-monorepo-template
$ npm install
```

## Configuration

Before the first running app configure your project environment variables:
<!---
-   copy `.env.example.{app_name}` to `{app_name}.{your_environment}.env` (where `app_name = api | admin` - current monorepo api name; `your_environment= development | production | testing | gitpod | ...` - current environment; example: `api..env.development` and `admin..env.development`) [required] 
-   open `.env.example` and read comments for every environment variables for more information [optional] or reade detail description of all configuration parameters in following documents:
    - [api.production.env](docs/api-configuration.md)
    - [admin.production.env](docs/admin-api-configuration.md)
-   set up correct environments variables for every api [required] 
-   if you want use TypeORM migrations CLI, you mast create `ormconfig.js` from `ormconfig.example.js`* [optional] 
```
* You can running api on new clean db in two way:
  1. Sepup envirement variable `TYPEORM_MIGRATIONS_RUN = true`, that automaticaly run migrations on api start (default)
  2. Manualy run migration with `npm run migrate` command (for that you must configure `ormconfig.js` file)
```
  -->

## Running the app

```bash
# Development mode
$ npm run start:dev

# Production mode
$ npm run build
$ npm run start:prod
```

more scripts view in `package.json` file.

## Db migrations
<!---
```bash

# run migration (running all migartions)
$ npm run migrate

# migration rollback (rollback only last migration!)
$ npm run migration:revert

# create new migration manually
$ npm run migration:create -- "YouMigrationName"

# generate new migration from entity changes you made
$ npm run migration:generate -- "YouMigrationName"

```
  -->
## Tests

**WIP...**

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## APIs docs

<!---
- **social-security-api**
    - Swagger [https://api.social.openstat.org.ua/swagger](https://api.social.openstat.org.ua/swagger)
    - OpenAPI Specification [https://api.social.openstat.org.ua/swagger-json](https://api.social.openstat.org.ua/swagger-json)
    - Api monitoring ui [https://api.social.openstat.org.ua/swagger-stats/ui](https://api.social.openstat.org.ua/swagger-stats/ui)
- **admin-api**
    - Swagger [https://admin.social.openstat.org.ua/swagger](https://admin.social.openstat.org.ua/swagger)
    - OpenAPI Specification [https://admin.social.openstat.org.ua/swagger-json](https://admin.social.openstat.org.ua/swagger-json)
  -->

## Database schema

<!---
![](docs/assets/db-schema-light.png)
  -->
  
## Project structure tree
```
    ├─ apps                     - main project folder with monorepo apps (@see https://docs.nestjs.com/cli/monorepo#monorepo-mode)
    │  ├─ main-api              - main-api files in standard Nest api structure
    |  |  └─ ...                
    │  └─ service-x             - service-x files in standard Nest api structure
    |      └─ ...               
    ├─ dist                     - folder with compiled *.js files (has same structure with /apps, /libs)
    |   └─ ...                  
    ├─ docs                     - api documents and assets
    ├─ database                 - database management files
    │  ├─ _pgmigrations         - db migrations files
    │  ├─ _seeds                - db seeds files (custom implementations with prisma runner)
    |  └─ sql                   - sql files and scripts
    |  schema.prisma            - prisma schema file (https://www.prisma.io/docs/concepts/components/prisma-schema/)
    ├─ environment              - app environment files (with same folder structure as apps/)
    │  ├─ main-api              - folder with main-api env files
    |  |  .env                  - default main-api env file
    |  └─ service-x             - folder with service-x env files
    |     .env                  - default service-x env file
    |  .env                     - default project env file (with db config and other used in all apps)
    ├─ libs                     - own libs sharing between monorepo apps
    │  ├─ common                - lib with common modules? configs and general nestjs entities files
    |  └─ prisma                - custom prisma service wrapper
    └─ node_modules             - nodejs third-party libs and dependencies for current project
       └─ ...                   
    .eslintrc.js                - eslint config
    .gitignore                  - Git untracked files list
    .prettierrc                 - prettier configuration file
    .prettierignore             - prettier ignored files list
    nest-cli.json               - nest-cli configuration file
    ormconfig.example.js        - example typeorm configuration file, used for working with migrations CLI
    package.json                - npm manifest file
    package-lock.json           - autogenerated file using by npm
    README.md                   - project readme file
    tsconfig.build.json         - ts compiler build configuration
    tsconfig.json               - typescript compiler configuration
```

## Support 

Find bug? - Report it:
 - on [Gitlab]() 
 - or in [Trello]()
