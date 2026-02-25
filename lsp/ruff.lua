return {
  cmd = { vim.g.python3_host_prog, "-m", "ruff", "server" },
  filetypes = { "python" },
  root_markers = { ".git", "pyproject.toml", "setup.py", "requirements.txt" },
  single_file_support = true,
}
