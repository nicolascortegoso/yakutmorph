from importlib.resources import files


def get_file_path(file_path: str) -> str:
    """
    Returns the absolute path of a file shipped inside the package.

    :param file_path: The path relative to the package root, e.g. 'data/reranker.onnx'.
    :return: The absolute filesystem path, as a string (sfst_transduce,
        sentencepiece and onnxruntime all expect a real file path).
    """
    return str(files('yakutmorph').joinpath(file_path))
