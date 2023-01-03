#! /bin/sh

# Bail run on process fail
set -o errexit
set -o nounset

# Handle sigterm gracefully
term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143;
}

trap term_handler TERM

# This should be taken care of by the deployment tools for production
export PYTHONBREAKPOINT=ipdb.set_trace
poetry install

if [ "${DEBUG}" = "true" ]
then
    echo "Starting app in ASGI mode..."
    until uvicorn main:app --reload --port ${PORT} --host 0.0.0.0; do
        echo "Development server crashed... restarting" >&2
        sleep 3;
    done

elif [ "${APP_TESTING}" = "True" ]; then
    export DEBUG=True
    pytest -v --cov=.

else
    gunicorn main:app
fi
