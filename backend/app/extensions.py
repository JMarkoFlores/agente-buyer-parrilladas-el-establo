"""
Extensiones de la aplicación Flask.
Inicializa SQLAlchemy y CORS para su posterior vinculación con la aplicación.
"""
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

db = SQLAlchemy()
cors = CORS()
