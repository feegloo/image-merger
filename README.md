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

"matrix" (supports 2x2, 3x2, 2x3)

merge in 2x2
```
./script 2x2
```


merge in 3x2 "matrix" (3 columns, 2 rows)
```
./script 3x2
```
