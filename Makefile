.PHONY: build up down bash composer-install create-project

up:
	docker compose up -d --wait

down:
	docker compose down --remove-orphans

bash:
	docker exec -it php bash

create-project:
	docker exec -it php composer create-project symfony/skeleton .

RETRY = for i in 1 2 3; do $(1) && break || (echo "Attempt $$i failed, retrying..."; sleep 5); done

.PHONY: composer-install

composer-install:
	docker exec -it php bash -c '$(call RETRY,composer install)'
	docker exec -it php bash -c '$(call RETRY,composer require symfony/orm-pack --no-interaction)'
	docker exec -it php bash -c '$(call RETRY,composer require --dev symfony/maker-bundle --no-interaction)'
	docker exec -it php php bin/console doctrine:database:create

build: up create-project composer-install
	@echo "Build complete."

console:
	docker exec -it php php bin/console $(filter-out $@,$(MAKECMDGOALS))

%:
	@: