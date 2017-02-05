# Jekyll Category Pages Generator

A Jekyll plugin to generate pages for a category in a data file located in _data folder

## How to use

```
page_generator:
  - data_file: '' # the file in _data folder for which you want to its data to generate pages
    parent_template: '' # this is for the parent category
    child_template: '' # this is for the child category of the parent category
    parent_key: '' # the parent key that will be used to create pages into the parent_template
    sub_key: '' # the child (sub category) key used to create pages into the child_template
    out_dir: '' # Better to name it after your data file (e.x. data_file = menu, destination_diretory = menu)
```
