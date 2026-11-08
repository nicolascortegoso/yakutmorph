# check=skip=FromPlatformFlagConstDisallowed
# The yakutmorph MCP server over HTTP, for hosting it publicly (Cloud Run,
# AWS App Runner, Render, a Hugging Face Space...). Built from this folder,
# so the image has the lexicon, transducers and model as they are here.
#
#   docker build -t yakutmorph-mcp .
#   docker run --rm -p 8000:8000 yakutmorph-mcp
#   -> MCP endpoint http://localhost:8000/mcp, status page http://localhost:8000/health
#
# Settings (environment variables, e.g. docker run -e PORT=8080 ...):
#   PORT                            port to listen on (default 8000; hosts usually set it)
#   YAKUTMORPH_MCP_MAX_TEXT_CHARS   longest text accepted (default 5000; 0 = no limit)
#   YAKUTMORPH_MCP_NO_EXAMPLES=1    do not offer find_examples (the corpus sentences)

# linux/amd64 on purpose (the check on line 1 is skipped for it): sfst-transduce publishes Linux wheels for x86-64 only, and
# cloud hosts run x86-64. On an Apple Silicon Mac, Docker emulates it.
FROM --platform=linux/amd64 python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PORT=8000

WORKDIR /src
COPY pyproject.toml README.md LICENSE ./
COPY yakutmorph ./yakutmorph
RUN pip install ".[mcp]" && rm -rf /src

# Run as an unprivileged user.
RUN useradd --create-home --uid 1000 app
USER app
WORKDIR /home/app

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s \
  CMD python -c "import os, urllib.request; urllib.request.urlopen(f'http://127.0.0.1:{os.environ[\"PORT\"]}/health')"

CMD ["yakutmorph-mcp", "--http", "--host", "0.0.0.0"]
