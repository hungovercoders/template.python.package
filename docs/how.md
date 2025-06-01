# How this Template was Made

test again

## Initialise Repo and Environment

1. **Created a new repository on GitHub.**
      - Gave an appropriate name and description.
      - Added a README file.
      - Added a .gitignore file for Python.
      - Selected a license (MIT License).

    ![Github Repo](./images/github_create_repo.png)

1. **Added Copilot Context File**
      - Created a [`.github/copilot-instructions.md`](https://github.com/hungovercoders/template.python.package/blob/main/.github/copilot-instructions.md){target="_blank"} file to provide context for Copilot.

1. **Opened in codespaces and amended environment configuration.**
      - Added a [`devcontainer.json`](https://github.com/hungovercoders/template.python.package/blob/main/.devcontainer/devcontainer.json){target="_blank"} file to configure the development environment.
      - Added a [requirements](https://github.com/hungovercoders/template.python.package/blob/main/.devcontainer/requirements.txt){target="_blank"} file for the packages required for development.

1. **Reopened the codespace to confirm devcontainer configuration**
    - Confirmed VS code extensions installed.
    - Leveraged errorlens and spell checker to clean-up any markdown or spelling errors.

    ![Error Lens and Spell Checker](./images/errorlens_spellcheck.PNG)

    - Confirmed package requirements installed in the codespace.
  
    ```bash
    pip list
    ```

    ![Pip List](./images/pip_list.PNG)

## Published Documentation

1. **Created documentation**
   - Created a [`mkdocs.yml`](https://github.com/hungovercoders/template.python.package/blob/main/mkdocs.yml){target="_blank"} file to configure the documentation.
   - Created a `docs` directory with an initial [`index.md`](https://github.com/hungovercoders/template.python.package/blob/main/docs/index.md){target="_blank"} file.
   - Built the documentation using:

     ```bash
     mkdocs build --strict
     ```

   - Served the documentation locally to confirm it works:

     ```bash
     mkdocs serve --strict
     ```

    ![Local Documentation Served](../images/local_mkdocs.PNG)

2. **Published documentation to GitHub Pages**
   - Created a `.github/workflows/gh-pages.yml` file with the necessary steps to build and deploy the documentation.
   - Committed and pushed changes to trigger the workflow.
   - Confirmed the documentation is available at `https://<username>.github.io/<repository-name>/`. e.g. [https://hungovercoders.github.io/template.python.package/](https://hungovercoders.github.io/template.python.package/)

## Initialise Package

## Create Changelog

## Publish Package to PyPI
