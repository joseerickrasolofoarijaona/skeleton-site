"""Envoie chaque application Django vers sa propre base de données.

hotels    -> base honey_hotels
vehicules -> base honey_vehicules
Les autres applications (comptes, sessions...) -> base 'default' (SQLite).
Aucune relation n'est autorisée entre deux bases différentes.
"""

APP_TO_DB = {
    "hotels": "hotels",
    "vehicules": "vehicules",
}


class HoneyRouter:

    def db_for_read(self, model, **hints):
        return APP_TO_DB.get(model._meta.app_label)

    def db_for_write(self, model, **hints):
        return APP_TO_DB.get(model._meta.app_label)

    def allow_relation(self, obj1, obj2, **hints):
        # Relation permise seulement à l'intérieur d'une même base
        return obj1._state.db == obj2._state.db

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        if app_label in APP_TO_DB:
            return db == APP_TO_DB[app_label]
        return db == "default"
