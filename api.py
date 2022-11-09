import os
from flask import Flask, send_file

app = Flask(__name__)


@app.route("/texshade/<string:hgvsp>")
def var2texshade(hgvsp):
    os.system(f"./var2texshade.sh {hgvsp}")
    return send_file(f"{hgvsp}.pdf")


if __name__ == "__main__":
    app.run(debug=True)
