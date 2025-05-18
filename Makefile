REQUIRED_VARS = POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_HOST POSTGRES_PORT MASK_SALT

.PHONY: up check-env create-env

# 1. Target to create a sample .env file (asks user to fill in values)
create-env:
	@if [ ! -f .env ]; then \
		echo "# Auto-generated .env" > .env; \
		echo "POSTGRES_DB=healthcare" >> .env; \
		echo "POSTGRES_USER=postgres" >> .env; \
		echo "POSTGRES_PASSWORD=postgres" >> .env; \
		echo "POSTGRES_HOST=db" >> .env; \
		echo "POSTGRES_PORT=5432" >> .env; \
		echo "MASK_SALT=salt_123" >> .env; \
		echo ".env file created. Please edit it to set real values."; \
	else \
		echo ".env already exists. Skipping creation."; \
	fi

# 2. Target to check that .env contains all required variables
check-env:
	@if [ ! -f .env ]; then \
		echo "ERROR: .env file not found. Please run 'make create-env' first."; \
		exit 1; \
	fi
	@for var in $(REQUIRED_VARS); do \
		if ! grep -q "^$$var=" .env; then \
			echo "ERROR: $$var not set in .env"; \
			exit 1; \
		fi \
	done
	@echo ".env file contains all required variables."

# 3. Main entry: checks .env and runs docker-compose up
docker-up: check-env
	docker-compose up --build
