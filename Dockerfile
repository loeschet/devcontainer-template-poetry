# Unified Dockerfile for both development and production
FROM python:3.12-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1

# Set work directory
#WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install pipx
RUN python -m pip install --user pipx \
    && python -m pipx ensurepath

# Add .local bin to PATH
ENV PATH="$PATH:/root/.local/bin"

# Install Poetry using pipx
RUN pipx install poetry

# Copy pyproject.toml and poetry.lock if they exist
COPY pyproject.toml* pyproject.toml*
COPY poetry.lock* poetry.lock*

# Set up the project
RUN if [ "$PYTHON_ENV" = "production" ]; then \
    echo "Existing project found. Installing dependencies..."; \
    poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-root; \
    fi

# Copy the rest of the application's code
COPY . .

# Run app in production (needs to be changed for specific use-case)
CMD if [ "$PYTHON_ENV" = "production" ]; then \
    echo "Running in production mode" && \
    python main.py; \
    fi