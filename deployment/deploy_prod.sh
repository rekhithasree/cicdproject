#!/bin/sh

# Define environment variables if not already set
export DB_PASSWORD=${DB_PASSWORD}

ssh root@134.209.159.114 <<EOF
  # Navigate to project directory
  cd cicdproject || { echo "Directory not found"; exit 1; }
  
  # Stash local changes if any
  git stash || { echo "Git stash failed"; exit 1; }

  # Pull latest code
  git pull || { echo "Git pull failed"; exit 1; }

  # Apply stashed changes if any
  git stash pop || { echo "Git stash pop failed"; exit 1; }

  # Activate virtual environment
  if [ -f env/bin/activate ]; then
    source env/bin/activate
  else
    echo "Virtual environment not found"
    exit 1
  fi

  # Install dependencies
  pip install -r requirements.txt || { echo "Pip install failed"; exit 1; }
  
  # Make and apply migrations
  ./manage.py makemigrations || { echo "Migrations failed"; exit 1; }
  ./manage.py migrate --run-syncdb || { echo "Migration apply failed"; exit 1; }
  
  # Collect static files
  ./manage.py collectstatic --noinput || { echo "Collectstatic failed"; exit 1; }
  
  # Restart services
  sudo service gunicorn restart || { echo "Gunicorn restart failed"; exit 1; }
  sudo service nginx restart || { echo "Nginx restart failed"; exit 1; }
  
  exit
EOF
