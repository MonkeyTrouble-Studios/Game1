import os
import string
import random

from flask import Flask, render_template, redirect, request
from tempfile import mkdtemp
from cs50 import SQL
from werkzeug.exceptions import default_exceptions, HTTPException, InternalServerError

from helpers import apology, usd

app = Flask(__name__)

# Ensure templates are auto-reloaded
app.config["TEMPLATES_AUTO_RELOAD"] = True

# Only enable Flask debugging if an env var is set to true
app.debug = os.environ.get('FLASK_DEBUG') in ['true', 'True']

# Get app version from env
app_version = os.environ.get('APP_VERSION')

@app.after_request
def after_request(response):
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response

# Custom filter
app.jinja_env.filters["usd"] = usd

# Configure session to use filesystem (instead of signed cookies)
app.config["SESSION_FILE_DIR"] = mkdtemp()
app.config["SESSION_PERMANENT"] = True
app.config["SESSION_TYPE"] = "filesystem"

db = SQL("postgres://nteusbnd:xit38Jkon_WSPbl0l7wJN6IankfRnBpw@lallah.db.elephantsql.com:5432/nteusbnd")


@app.route('/', methods=['GET'])
def index() :
    return 'Hey'


@app.route('/test', methods=['GET'])
def test_app() :
    return render_template('test.html')


@app.route('/make-server', methods=['POST'])
def make_server() :
    try :
        server_ip =  request.form['ip']
        server_code = get_new_code()
        db.execute("INSERT INTO servers (ip, code) VALUES (:ip, :c)", ip=server_ip, c=server_code)
        db.execute("COMMIT")
        return {
            'code': server_code,
            'error': 'none'
        }
    except Exception as e :
        return {
            'error': e.args
        }


@app.route('/get-server', methods=['POST'])
def get_server() :
    try :
        server_code = request.form['code']
        ip_select = db.execute("SELECT * FROM servers WHERE code=:c", c=server_code)
        if len(ip_select) == 0 :
            return {
                'error': 'not found'
            }
        return {
            'error': 'none',
            'ip': ip_select[0]['code']
        }
    except Exception as e :
        return {
            'error': e.args
        }


@app.route('/delete-server', methods=['POST'])
def delete_server() :
    server_code = request.form['code']
    db.execute("DELETE FROM servers WHERE code=:c", c=server_code)
    db.execute("COMMIT")


def get_new_code() :
    code_out = get_random_string(4)
    while db.execute("SELECT COUNT(pk) FROM servers WHERE code=:c", c=code_out)[0]['count'] > 0 :
        code_out = get_random_string(4)
    return code_out

def get_random_string(length) :

    letters = string.ascii_uppercase
    return ''.join(random.choice(letters) for i in range(length))


def errorhandler(e):
    """Handle error"""
    try :
        e.name
        if "Not Found" in e.name :
            return 'Not Found'
    except :
        pass

    if not isinstance(e, HTTPException):
        e = InternalServerError()
        return e
    return apology(e.name, e.code)


for code in default_exceptions:
    app.errorhandler(code)(errorhandler)

if __name__ == "__main__":
    # Setting debug to True enables debug output. This line should be
    # removed before deploying a production app.
    app.debug = True
    app.run()