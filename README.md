# Welcome to Knowledge Hub

Hello there! 👋


We recognize that knowledge is power, and in our constantly evolving field, it's crucial to keep up with the latest technologies, methodologies, and best practices.


This repository is a live document, and **we encourage everyone to contribute**. If you have something valuable to share, don't hesitate to make a contribution. Remember, what may be obvious to you could be new to someone else.

## How to add a new Page

1. Create a new `.md` file under in the `docs/` folder
2. Add the new page to the `mkdocs.yml` file under the `nav` section
    - **Do not put `docs/` prefix on the filepath**
3. Commit and push your changes to the `main` branch
4. GitHub Action will automatically build and deploy the changes to the website.


## About this website

**Stack**

| Name | Description |
| --- | --- |
| [mkDocs](https://www.mkdocs.org/) | Docs static site generator  |
| [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) | Material theme for mkDocs |

### Steps to run it locally

!!! Note About Static Files(images, pdfs, etc.)
    Put your static assets into [github.com/hepapi/knowledge-hub-assets](https://github.com/hepapi/knowledge-hub-assets) repository. 
    Then, you can reference them in your markdown files like this:
    ```markdown
    #TODO: add example
    ```


1. Make sure `python3` is installed
1. Install python requirements
    ```bash
    pip install mkdocstrings[python]
    pip install mkdocs-material 
    ```
2. Clone the repository & `cd` into it
3. Run the local server
    ```bash
    mkdocs serve
    ```
