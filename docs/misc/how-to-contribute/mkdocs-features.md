
# MkDocs and Material Theme Features
---

#### TO-DO Lists

- [x] Lorem ipsum dolor sit amet, consectetur adipiscing elit
- [ ] Vestibulum convallis sit amet nisi a tincidunt
- [ ] Aenean pretium efficitur erat

---

#### [Admonitions or Notes](https://squidfunk.github.io/mkdocs-material/reference/admonitions/)

- **Supported Icon Types**: note, abstract, info, tip, success, question, warning, failure, danger, error, example, quote

!!! warning "Warning Note Header"
    You can write notes like this to provide additional information or warnings.

!!! success "We've done it!"
    Works for code blocks as well
    ```bash
    sudo apt install postgresql-client-<version-number>
    ```

??? abstract "Collapsible Note (collapsed)"

    Lorem ipsum dolor sit amet, consectetur adipiscing elit...

???+ example "Collapsible Note (expanded)"

    Lorem ipsum dolor sit amet, consectetur adipiscing elit...


!!! example "Tabbed Note"

    === "Ubuntu"

        ```bash
        apt install vim
        ```
    === "RHEL/CentOS/AL2"

        ```bash
        yum install vim
        ```
---

#### Code block with title

``` py title="here is a codeblock title"
def bubble_sort(items):
    for i in range(len(items)):
        for j in range(len(items) - 1 - i):
            if items[j] > items[j + 1]:
                items[j], items[j + 1] = items[j + 1], items[j]
```

---

#### Buttons

[Button](#){ .md-button }
[Primary Button](#){ .md-button .md-button--primary }
[Emoji Button :fontawesome-solid-paper-plane:](#){ .md-button }
---

#### [Mermaid Diagrams](https://squidfunk.github.io/mkdocs-material/reference/diagrams/)

##### Sequence Diagram

``` mermaid
sequenceDiagram
  autonumber
  Alice->>John: Hello John, how are you?
  loop Healthcheck
      John->>John: Fight against hypochondria
  end
  Note right of John: Rational thoughts!
  John-->>Alice: Great!
  John->>Bob: How about you?
  Bob-->>John: Jolly good!
```

##### Flow Chart

``` mermaid
graph LR
  A[Start] --> B{Error?};
  B -->|Yes| C[Hmm...];
  C --> D[Debug];
  D --> B;
  B ---->|No| E[Yay!];
```

##### State Diagram

``` mermaid
stateDiagram-v2
  state fork_state <<fork>>
    [*] --> fork_state
    fork_state --> State2
    fork_state --> State3

    state join_state <<join>>
    State2 --> join_state
    State3 --> join_state
    join_state --> State4
    State4 --> [*]
```