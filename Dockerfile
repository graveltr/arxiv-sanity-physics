# Use the official Python 3.8.10 base image
FROM python:3.8.10-slim

# Install required system packages
RUN apt-get update && apt-get install -y \
    cron \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Copy the supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add the cron job
RUN echo "0 0 * * * /app/run_arxiv_tasks.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/arxiv_cron
RUN chmod 0644 /etc/cron.d/arxiv_cron
RUN crontab /etc/cron.d/arxiv_cron

# Ensure cron and supervisord logs are accessible
RUN touch /var/log/cron.log /var/log/supervisord.log

# Expose the port that the Flask app will run on
EXPOSE 5000

# Run supervisord to manage both the cron job and the Flask app
CMD ["/usr/bin/supervisord"]
