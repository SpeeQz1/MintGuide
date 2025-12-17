# The Linux Mint Community Wiki

## Introduction

### The original repository can be found on Codeberg: https://codeberg.org/SpeeQz1/MintGuide

<hr/>

![Introduction Preview](docs/assets/images/Preview.png)

Welcome to The Linux Mint Community Wiki repository. Here you can find the infrastructure used for hosting the wiki. You can find the wiki online at [Miraheze Instance](https://mintguide.miraheze.org/wiki/Main_Page).

Instructions on how to set it up are included bellow and further documentation on how the whole infrastructure setup can be found in [docs currently are not implemented]().

> NOTE: ⚠️ Warning this repo is still work in progress and subject to be heavily modified for now. ⚠️

## Instructions

<hr/>

### 1. Installation

#### Run WITHOUT GitOps (Default)

1. (You can skip this step if you have `Docker Desktop` or `Docker Engine`) Install [Docker Engine](https://docs.docker.com/engine/install/) from Docker's website.
2. Clone the repository in whichever directory you want.

```sh
git clone https://github.com/path/to/repo.git
```

4. Create the necessary environmental variables, an `.env.template` and `.env.example` are both provided.
5. Use the `./scripts.generate-keys.sh` file to generate the necessary keys.
6. Run the `docker compose` command in the directory where the `docker-compose.yaml` file is (`docker compose` automatically chooses the file).

```sh
docker compose up -d
```

#### Run WITH GitOps (Optional)

```sh
docker compose --profile gitops up -d
```

### 2. Commands

#### Stop all services

```sh
docker compose down
```

#### Stop all services (Delete all data)

```sh
docker compose down -v
```

#### Stop only GitOps (keep wiki running)

```sh
docker compose stop doco-cd
```

#### Start only GitOps (if wiki already running)

```sh
docker compose --profile gitops up -d doco-cd
```

#### View logs

```sh
# All services
docker compose logs -f

# Only MediaWiki
docker compose logs -f mediawiki

# Only GitOps (when running)
docker compose logs -f doco-cd
```

#### Update LocalSettings.php

If you have modified the `LocalSettings.template.php` file, you can use the `update-config.sh` script:

```sh
docker exec -it wiki /update-config.sh
```

#### Start terminal inside wiki

```sh
docker exec -it wiki bash
```

## Contributions

<hr/>

Big shoutout to the [Linux Mint Community](https://discord.gg/mint) Discord server for helping out in the project and collaborating to make this project real!
