from pathlib import Path
import os
from flask import Flask, send_file

app = Flask(__name__)


@app.route("/texshade/<string:hgvsp>")
def var2texshade(hgvsp):
    module_path=Path("./modules/var2texshade/")
    os.system(f"{module_path.joinpath('var2texshade.sh')} {hgvsp}")
    return send_file(f"{module_path.joinpath(f'{hgvsp}.pdf')}")


if __name__ == "__main__":
    app.run(debug=True)
