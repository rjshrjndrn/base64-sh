---
title: "Yaml Magic"
date: 2022-06-30T11:09:27+02:00
draft: false
description: "Do programming with YAML."
---

Yaml has some neat features for keeping the code dry.

Aliases: Like variables, noted with `&`
Anchors: Like references, noted with `*`

Check the following example. Save the following file as example.yaml

```yaml
---
- &CENTER 
   x: 1
   y: 2
- &LEFT { x: 0, y: 2 }
- &BIG { r: 10 }
- &SMALL { r: 1 }
# All the following maps are equal:

- # Explicit keys
  x: 1
  y: 2
  r: 10
  label: center/big

- # Merge one map
  << : *CENTER
  r: 10
  label: center/big

- # Merge multiple maps
  << : [ *CENTER, *BIG ]
  label: center/big

- # Override
  << : [ *BIG, *LEFT, *SMALL ]
  x: 1
  label: center/big
- &LEFT { x: 0, y: 2 }
- &BIG { r: 10 }
- &SMALL { r: 1 }
# All the following maps are equal:

- # Explicit keys
  x: 1
  y: 2
  r: 10
  label: center/big

- # Merge one map
  << : *CENTER
  r: 10
  label: center/big

- # Merge multiple maps
  << : [ *CENTER, *BIG ]
  label: center/big

- # Override
  << : [ *BIG, *LEFT, *SMALL ]
  x: 1
  label: center/big
```

To check the output

```python
import yaml
with open(r'example.yaml') as file:
    cont = yaml.load(file,Loader=yaml.FullLoader)
    print(cont)
```
