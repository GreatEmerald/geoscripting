#!/bin/bash
input='Municipalities.html'
insert='<link rel="stylesheet" type="text\/css" href="width.css">'
after='<meta charset="utf-8"\/>'

sed -i "s/${after}/${after}\n${insert}/" ${input}
