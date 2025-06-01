# How this Template was Made

1. **Created a new repository on GitHub.** 
   - Gave an appropriate name and description.
   - Added a README file.
   - Added a .gitignore file for Python.
   - Selected a license (MIT License).

2. **Opened in codespaces and amended environment configuration.**
   - Added a `devcontainer.json` file to configure the development environment.
   - Added a requirements.txt file for the packages required for development.

3. **Reopened the codespace to confirm devcontainer configuration**
    - Confirmed extensions installed.
    - Leveraged errorlens to clean-up any markdown or spelling errors.

    - Confirmed required packages installed.
    ```
    pip list
    ```

4. **Created documentation**
   - Created a `mkdocs.yml` file to configure the documentation.
   - Created a `docs` directory with an initial `index.md` file.
   - Built the documentation using:
     ```
     mkdocs build --strict
     ```
   - Served the documentation locally to confirm it works:
     ```
     mkdocs serve
     ```