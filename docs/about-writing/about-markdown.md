# Markdown Syntax

### Links

```markdown
[Link Text](https://www.example.com)
```

### Images

Put a `!` in front of the link syntax.

```markdown
![Alt Text](https://www.example.com/image.png)
```

### Syntax Highlighting

Insert the language name after the first set of backticks.

````python
# ```python
import os
os.system("echo 'Hello World'")
````

````bash
# ```bash
export HELLO="world"
cat some-file | grep "hello"
````

````yaml
# ```yaml
some: key
another: key
````

### Tables

```markdown
| name | value |
| ---- | ----- |
| a    | b     |
```

You can align headers to the left, center, or right by adding colons to the header syntax.

```markdown
| --name-- | --value-- | description |
| :------- | :-------: | ----------: |
| a        |     b     |           c |
```


### Headers

```markdown
# H1 Header (biggest)

## H2 Header

### H3 Header

#### H4 Header

##### H5 Header

###### H6 Header (smallest)
```
