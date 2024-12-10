```bash
mkdir notebooks
```

```bash
docker build -t jupyter-kotlin .
```

```bash
docker run -p 8888:8888 -v $(pwd)/notebooks:/notebooks jupyter-kotlin
```
