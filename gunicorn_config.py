"""
Gunicorn configuration file for IT Inventory System.

This file configures Gunicorn for production deployment.
Adjust settings based on your server resources and requirements.
"""
import multiprocessing
import os

# =============================================================================
# Server Socket
# =============================================================================
# Bind to localhost on port 8000 (Nginx/Apache will proxy to this)
bind = "127.0.0.1:8000"

# The maximum number of pending connections
backlog = 2048

# =============================================================================
# Worker Processes
# =============================================================================
# Number of worker processes
# Rule of thumb: (2 x $num_cores) + 1
workers = multiprocessing.cpu_count() * 2 + 1

# The type of workers to use
# Options: sync, eventlet, gevent, tornado, gthread
worker_class = "sync"

# The maximum number of simultaneous clients per worker
worker_connections = 1000

# Workers silent for more than this many seconds are killed and restarted
timeout = 30

# The number of seconds to wait for requests on a Keep-Alive connection
keepalive = 2

# Maximum number of requests a worker will process before restarting
# Helps prevent memory leaks
max_requests = 1000
max_requests_jitter = 50

# =============================================================================
# Logging
# =============================================================================
# Access log file path
accesslog = os.environ.get("GUNICORN_ACCESS_LOG", "/var/log/inventory/gunicorn-access.log")

# Error log file path
errorlog = os.environ.get("GUNICORN_ERROR_LOG", "/var/log/inventory/gunicorn-error.log")

# The granularity of Error log outputs
# Options: debug, info, warning, error, critical
loglevel = os.environ.get("GUNICORN_LOG_LEVEL", "info")

# Access log format
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'

# =============================================================================
# Process Naming
# =============================================================================
# A base to use with setproctitle for process naming
proc_name = "inventory_system"

# =============================================================================
# Server Mechanics
# =============================================================================
# Daemonize the Gunicorn process
# Set to False when using systemd or supervisor
daemon = False

# A filename to use for the PID file
pidfile = os.environ.get("GUNICORN_PID_FILE", "/var/run/inventory/gunicorn.pid")

# Switch worker processes to run as this user
user = os.environ.get("GUNICORN_USER", "www-data")

# Switch worker process to run as this group
group = os.environ.get("GUNICORN_GROUP", "www-data")

# A directory to use for the worker heartbeat temporary file
tmp_upload_dir = None

# Restart workers when code changes (development only)
reload = os.environ.get("GUNICORN_RELOAD", "false").lower() == "true"

# =============================================================================
# SSL Configuration (if terminating SSL at Gunicorn)
# =============================================================================
# Uncomment and configure if you want Gunicorn to handle SSL
# (Usually handled by Nginx/Apache instead)

# keyfile = "/path/to/keyfile.key"
# certfile = "/path/to/certfile.crt"
# ssl_version = 2  # TLS
# cert_reqs = 0  # ssl.CERT_NONE
# ca_certs = None
# ciphers = None

# =============================================================================
# Server Hooks
# =============================================================================

def on_starting(server):
    """Called just before the master process is initialized."""
    server.log.info("Starting Gunicorn server")


def on_reload(server):
    """Called to recycle workers during a reload via SIGHUP."""
    server.log.info("Reloading Gunicorn server")


def when_ready(server):
    """Called just after the server is started."""
    server.log.info("Gunicorn server is ready. Spawning workers")


def pre_fork(server, worker):
    """Called just before a worker is forked."""
    pass


def post_fork(server, worker):
    """Called just after a worker has been forked."""
    server.log.info(f"Worker spawned (pid: {worker.pid})")


def pre_exec(server):
    """Called just before a new master process is forked."""
    server.log.info("Forked child, re-executing.")


def worker_int(worker):
    """Called just after a worker exited on SIGINT or SIGQUIT."""
    worker.log.info(f"Worker received INT or QUIT signal (pid: {worker.pid})")


def worker_abort(worker):
    """Called when a worker received the SIGABRT signal."""
    worker.log.info(f"Worker received SIGABRT signal (pid: {worker.pid})")


def pre_request(worker, req):
    """Called just before a worker processes the request."""
    pass


def post_request(worker, req, environ, resp):
    """Called after a worker processes the request."""
    pass


def child_exit(server, worker):
    """Called just after a worker has been exited."""
    server.log.info(f"Worker exited (pid: {worker.pid})")


def worker_exit(server, worker):
    """Called just after a worker has been exited."""
    server.log.info(f"Worker exited gracefully (pid: {worker.pid})")


def nworkers_changed(server, new_value, old_value):
    """Called just after num_workers has been changed."""
    server.log.info(f"Number of workers changed from {old_value} to {new_value}")


def on_exit(server):
    """Called just before exiting Gunicorn."""
    server.log.info("Shutting down Gunicorn server")
