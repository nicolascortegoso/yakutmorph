from pkg_resources import resource_filename


def get_file_path(file_path: str) -> str:
    path = resource_filename(__name__, file_path)
    return path
