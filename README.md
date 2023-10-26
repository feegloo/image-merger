# chatgpt-image-merger

### prepare

1. put your files into "convert" folder (siblings to `script.sh`)

```
chmod +x script.sh
```

2. output will be written to "convert/image.jpeg"
 
### usage

merge vertically
```
./script -v
```

merge horizontally
```
./script -h
```

merge in 2x2 "matrix" (supports NxM)
```
./script 2x2
```
