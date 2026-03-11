
from flask import jsonify

def register_debug_endpoints(app):
    @app.route("/debug/deps")
    def debug_deps():
        results = {}
        try:
            import osmnx
            results["osmnx"] = f"OK (version {osmnx.__version__})"
        except Exception as e:
            results["osmnx"] = f"ERROR: {e}"

        try:
            import networkx
            results["networkx"] = f"OK (version {networkx.__version__})"
        except Exception as e:
            results["networkx"] = f"ERROR: {e}"

        try:
            import shapely
            results["shapely"] = "OK"
        except Exception as e:
            results["shapely"] = f"ERROR: {e}"

        return jsonify(results)
