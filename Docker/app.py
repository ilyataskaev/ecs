import os
import random
from flask import Flask, render_template_string

app = Flask(__name__)

@app.route('/')
def index():
    container_id = os.popen('hostname').read().strip()
    random_color = "#{:06x}".format(random.randint(0, 0xFFFFFF))
    if 'COLOR' in os.environ:
      COLOR = os.environ.get('COLOR')
    else:
      COLOR = random_color
    template = """
    <html>
        <head>
            <title>Container ID</title>
            <style>
                body {
                    background-color: {{color}};
                    font-family: Arial, sans-serif;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                }
            </style>
        </head>
        <body>
            <h1>Container ID: {{container_id}} Version V.3 </h1>
        </body>
    </html>
    """

    return render_template_string(template, container_id=container_id, color=COLOR)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
