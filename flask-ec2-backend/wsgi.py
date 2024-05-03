#
# WSGI server for the production environment
#
from app import app

if __name__ == "__main__":
    app.run()
