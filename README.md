# chatgpt-image-merger

### prepare

1. put your files into "convert" folder (siblings to `script.sh`)

2. make `script.sh` executable

```
chmod +x script.sh
```

3. run script

```
./script.sh -h
```

4. output will be written to "convert/image.jpeg"
 
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

merge 2x2 (2 rows, 2 columns)
```
./script 2x2
```


merge 3x2 (3 rows, 2 columns)
```
./script 3x2
```
